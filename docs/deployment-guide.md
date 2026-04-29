# Evo CRM — Guia de Deploy

## Opções de Deploy

| Método | Complexidade | Recomendação |
|--------|-------------|--------------|
| Docker Compose (Dokploy) | ★★☆ | ✅ Recomendado para produção |
| Easypanel | ★★☆ | ✅ Alternativa gerenciada |
| Docker Compose local | ★☆☆ | Dev/staging |
| Kubernetes | ★★★ | Alta escala (não documentado) |

---

## Pré-requisitos

- Docker Engine 24+ e Docker Compose v2
- Servidor com mínimo:
  - CPU: 4 cores
  - RAM: 8 GB
  - Disco: 50 GB SSD
- Domínios configurados (HTTPS obrigatório em produção)

---

## Deploy com Docker Compose (Recomendado)

### 1. Preparar arquivos

```bash
# Clonar o repositório
git clone --recurse-submodules git@github.com:EvolutionAPI/evo-crm-community.git
cd evo-crm-community

# Copiar template de variáveis
cp _env.dokploy.example .env
```

### 2. Configurar variáveis obrigatórias

Editar `.env` com valores reais:

```env
# Domínios (com HTTPS)
BACKEND_URL=https://api.seudominio.com
FRONTEND_URL=https://app.seudominio.com
CORS_ORIGINS=https://app.seudominio.com,https://api.seudominio.com

# Banco
POSTGRES_PASSWORD=<senha_forte>

# Redis
REDIS_PASSWORD=<senha_forte>

# Secrets (gerar novos para cada deploy!)
SECRET_KEY_BASE=<openssl rand -base64 48>
JWT_SECRET_KEY=<openssl rand -base64 48>
DOORKEEPER_JWT_SECRET_KEY=<openssl rand -base64 48>
ENCRYPTION_KEY=<fernet_key>
EVOAI_CRM_API_TOKEN=<openssl rand -hex 32>
BOT_RUNTIME_SECRET=<openssl rand -hex 32>
```

### 3. Subir serviços

```bash
# Subir tudo (com inicialização automática)
docker-compose -f docker-compose.dokploy.yaml up -d

# Acompanhar logs de inicialização
docker-compose -f docker-compose.dokploy.yaml logs -f evo_auth_init evo_crm_init evo_processor_init

# Verificar saúde
docker-compose -f docker-compose.dokploy.yaml ps
```

### 4. Ordem de dependências (automática via healthchecks)

```
① postgres + redis
② evo_auth_init    → seed do banco de autenticação
③ evo-auth         → serviço de autenticação
④ evo_crm_init     → seed do banco CRM
⑤ evo-core         → core service Go (sem dependência de init)
⑥ evo_processor_init → aguarda tabela evo_core_agents
⑦ evo-processor    → serviço de processamento IA
⑧ evo-bot-runtime  → runtime de bots
⑨ evo-gateway      → gateway/proxy
⑩ evo-frontend     → interface web
⑪ evo-auth-sidekiq + evo-crm-sidekiq → workers assíncronos
```

---

## Deploy no Easypanel

### Compatibilidade

✅ O projeto é totalmente compatível com Easypanel via Docker Compose.

### Passos

```bash
# 1. Instalar Easypanel no servidor
docker run --rm -it \
  -v /etc/easypanel:/etc/easypanel \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  easypanel/easypanel setup

# 2. Acessar UI: http://<ip-servidor>:3000
```

No painel Easypanel:
1. Criar novo projeto: `evo-crm`
2. Adicionar serviços com base no `docker-compose.dokploy.yaml`
3. Configurar variáveis de ambiente por serviço
4. Configurar domínios:
   - `evo-gateway` → `api.seudominio.com` (porta 3030)
   - `evo-frontend` → `app.seudominio.com` (porta 80)
5. Habilitar SSL automático (Let's Encrypt)

---

## Configuração de Domínios

### Roteamento via Gateway

Todos os serviços são expostos através do `evo-gateway` na porta 3030:

```nginx
# Roteamento interno (gerenciado pelo gateway)
/api/v1/auth/*    → evo-auth:3001
/api/v1/*         → evo-crm:3000  (padrão)
/evo-core/*       → evo-core:5555
/processor/*      → evo-processor:8000
```

### DNS necessário

```
api.seudominio.com    → IP do servidor (evo-gateway:3030)
app.seudominio.com    → IP do servidor (evo-frontend:80)
```

---

## Volumes Persistentes

Os dados persistentes são armazenados em volumes Docker:

```yaml
volumes:
  postgres_data:    # Dados do PostgreSQL (CRÍTICO — backup obrigatório)
  redis_data:       # Dados do Redis (cache/filas)
  processor_logs:   # Logs do evo-processor
```

### Backup do PostgreSQL

```bash
# Backup manual
docker-compose -f docker-compose.dokploy.yaml exec postgres \
  pg_dump -U postgres evo_community > backup_$(date +%Y%m%d).sql

# Restaurar backup
docker-compose -f docker-compose.dokploy.yaml exec -T postgres \
  psql -U postgres evo_community < backup_20260429.sql
```

---

## Atualizar para Nova Versão

```bash
# 1. Atualizar submodules
git pull
git submodule update --remote --merge

# 2. Baixar novas imagens
docker-compose -f docker-compose.dokploy.yaml pull

# 3. Recriar containers (com downtime mínimo)
docker-compose -f docker-compose.dokploy.yaml up -d --force-recreate
```

---

## Monitoramento

### Health Checks

```bash
# Verificar todos os serviços
curl http://localhost:3001/health      # evo-auth
curl http://localhost:3000/health/live # evo-crm
curl http://localhost:5555/health      # evo-core
curl http://localhost:5555/ready       # evo-core readiness
curl http://localhost:5555/metrics     # Prometheus metrics
```

### Logs em Produção

```bash
# Logs em tempo real
docker-compose -f docker-compose.dokploy.yaml logs -f --tail=100

# Logs de um serviço específico
docker-compose -f docker-compose.dokploy.yaml logs -f evo-core

# Logs com filtro
docker-compose -f docker-compose.dokploy.yaml logs evo-crm 2>&1 | grep ERROR
```

---

## Considerações de Segurança

### ⚠️ Checklist Obrigatório Antes de Produção

- [ ] Todos os secrets alterados (não usar valores de exemplo)
- [ ] HTTPS configurado em todos os endpoints públicos
- [ ] Firewall configurado (portas internas não expostas publicamente)
- [ ] Backup automático do PostgreSQL configurado
- [ ] Variável `RAILS_ENV=production` definida
- [ ] CORS_ORIGINS limitado aos domínios legítimos
- [ ] Multi-tenancy implementado (se múltiplos usuários)

### Portas que NÃO devem ser expostas publicamente

```
5432  # PostgreSQL
6379  # Redis
3000  # evo-crm (usar via gateway)
3001  # evo-auth (usar via gateway)
5555  # evo-core (usar via gateway)
8000  # evo-processor (usar via gateway)
8080  # evo-bot-runtime (interno)
```

### Portas expostas publicamente

```
3030  # evo-gateway (API)
80    # evo-frontend (via HTTPS/443)
443   # HTTPS (configurar no load balancer/nginx externo)
```

---

## Troubleshooting

### Serviço não inicializa

```bash
# Ver logs detalhados
docker-compose -f docker-compose.dokploy.yaml logs evo-auth

# Reiniciar serviço específico
docker-compose -f docker-compose.dokploy.yaml restart evo-auth

# Verificar se init jobs completaram
docker-compose -f docker-compose.dokploy.yaml ps evo_auth_init
```

### Erro de conexão ao banco

```bash
# Verificar se postgres está saudável
docker-compose -f docker-compose.dokploy.yaml exec postgres pg_isready

# Conectar manualmente
docker-compose -f docker-compose.dokploy.yaml exec postgres psql -U postgres evo_community
```

### Reset completo (⚠️ destrutivo)

```bash
# Parar tudo e remover volumes
docker-compose -f docker-compose.dokploy.yaml down -v

# Recriar do zero
docker-compose -f docker-compose.dokploy.yaml up -d
```
