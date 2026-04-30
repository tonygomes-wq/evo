# Guia de Uso - Docker Compose Local

Este guia explica como rodar o Evo CRM localmente usando os arquivos do sistema em vez de imagens do repositório.

---

## 📁 Arquivos Criados

1. **`docker-compose.local.yaml`** - Configuração Docker Compose para desenvolvimento local
2. **`.env.local`** - Variáveis de ambiente com valores de desenvolvimento
3. **`docker-compose.dokploy.yaml.backup`** - Backup do arquivo original

---

## 🚀 Como Usar

### Opção 1: Usar o Novo Docker Compose (Recomendado)

```powershell
# 1. Parar containers antigos
docker stop $(docker ps -aq)

# 2. Subir com o novo docker-compose
docker-compose -f docker-compose.local.yaml --env-file .env.local up -d

# 3. Acompanhar logs
docker-compose -f docker-compose.local.yaml logs -f
```

### Opção 2: Rebuild Completo

```powershell
# 1. Parar e remover tudo
docker-compose -f docker-compose.local.yaml down -v

# 2. Rebuild das imagens
docker-compose -f docker-compose.local.yaml build --no-cache

# 3. Subir novamente
docker-compose -f docker-compose.local.yaml --env-file .env.local up -d
```

---

## 📊 Diferenças do Arquivo Original

### ✅ Vantagens do docker-compose.local.yaml

1. **Usa Código Local**
   - Build a partir das pastas do projeto
   - Não depende de imagens externas
   - Permite modificar código e rebuild

2. **Variáveis Hardcoded**
   - Senhas de desenvolvimento definidas
   - Não precisa de arquivo .env externo
   - Pronto para usar

3. **Volumes Montados**
   - Código local montado nos containers
   - Mudanças refletidas imediatamente
   - Facilita desenvolvimento

4. **Portas Expostas**
   - Todas as portas mapeadas para localhost
   - Fácil acesso aos serviços
   - Debug simplificado

### 📋 Estrutura de Pastas Necessária

```
evo/
├── docker-compose.local.yaml
├── .env.local
├── evo-auth-service-community-main/
│   └── Dockerfile
├── evo-ai-crm-community-main/
│   └── Dockerfile
├── evo-ai-core-service-community-main/
│   └── Dockerfile
├── evo-ai-processor-community-main/
│   └── Dockerfile
├── evo-bot-runtime-main/
│   └── Dockerfile
└── evo-ai-frontend-community-main/
    └── Dockerfile
```

---

## 🔧 Configurações

### Senhas de Desenvolvimento

```
PostgreSQL: evoai_dev_password
Redis: evoai_redis_pass
```

### Portas Expostas

| Serviço | Porta | URL |
|---------|-------|-----|
| Frontend | 5173 | http://localhost:5173 |
| CRM | 3000 | http://localhost:3000 |
| Auth | 3001 | http://localhost:3001 |
| Gateway | 3030 | http://localhost:3030 |
| Core | 5555 | http://localhost:5555 |
| Processor | 8000 | http://localhost:8000 |
| Bot Runtime | 8080 | http://localhost:8080 |
| PostgreSQL | 5432 | localhost:5432 |
| Redis | 6379 | localhost:6379 |
| MailHog UI | 8025 | http://localhost:8025 |

### Credenciais de Login

```
Email: tonygomes058@gmail.com
Senha: To811205ny@
```

---

## 📝 Comandos Úteis

### Ver Status dos Containers

```powershell
docker-compose -f docker-compose.local.yaml ps
```

### Ver Logs de um Serviço Específico

```powershell
# Auth
docker-compose -f docker-compose.local.yaml logs -f evo-auth

# CRM
docker-compose -f docker-compose.local.yaml logs -f evo-crm

# Core
docker-compose -f docker-compose.local.yaml logs -f evo-core

# Processor
docker-compose -f docker-compose.local.yaml logs -f evo-processor
```

### Reiniciar um Serviço

```powershell
docker-compose -f docker-compose.local.yaml restart evo-auth
```

### Rebuild de um Serviço

```powershell
docker-compose -f docker-compose.local.yaml build evo-auth
docker-compose -f docker-compose.local.yaml up -d evo-auth
```

### Executar Comando em um Container

```powershell
# Rails console no Auth
docker-compose -f docker-compose.local.yaml exec evo-auth bundle exec rails c

# Rails console no CRM
docker-compose -f docker-compose.local.yaml exec evo-crm bundle exec rails c

# Bash no Processor
docker-compose -f docker-compose.local.yaml exec evo-processor bash

# PostgreSQL
docker-compose -f docker-compose.local.yaml exec postgres psql -U postgres -d evo_community
```

### Parar Tudo

```powershell
docker-compose -f docker-compose.local.yaml down
```

### Parar e Remover Volumes

```powershell
docker-compose -f docker-compose.local.yaml down -v
```

---

## 🐛 Troubleshooting

### Problema: Container não inicia

```powershell
# Ver logs detalhados
docker-compose -f docker-compose.local.yaml logs evo-auth

# Rebuild do container
docker-compose -f docker-compose.local.yaml build --no-cache evo-auth
docker-compose -f docker-compose.local.yaml up -d evo-auth
```

### Problema: Erro de permissão

```powershell
# No Windows, pode ser necessário compartilhar drives no Docker Desktop
# Settings > Resources > File Sharing
```

### Problema: Porta já em uso

```powershell
# Verificar o que está usando a porta
netstat -ano | findstr :3001

# Matar o processo (substitua PID)
taskkill /PID <PID> /F
```

### Problema: Banco de dados não conecta

```powershell
# Verificar se postgres está healthy
docker-compose -f docker-compose.local.yaml ps postgres

# Reiniciar postgres
docker-compose -f docker-compose.local.yaml restart postgres

# Verificar logs
docker-compose -f docker-compose.local.yaml logs postgres
```

---

## 🔄 Migrar dos Containers Antigos

### Passo 1: Fazer Backup do Banco

```powershell
docker exec evo-crm-community-main-postgres-1 pg_dump -U postgres evo_community > backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql
```

### Passo 2: Parar Containers Antigos

```powershell
docker stop $(docker ps -aq --filter "name=evo-crm-community-main")
```

### Passo 3: Subir Novo Stack

```powershell
docker-compose -f docker-compose.local.yaml --env-file .env.local up -d
```

### Passo 4: Restaurar Backup (se necessário)

```powershell
Get-Content backup_20260430_020000.sql | docker exec -i evo-postgres-1 psql -U postgres -d evo_community
```

---

## ⚙️ Customização

### Mudar Senhas

Edite o arquivo `.env.local`:

```env
POSTGRES_PASSWORD=sua_nova_senha
REDIS_PASSWORD=sua_nova_senha_redis
```

Depois rebuild:

```powershell
docker-compose -f docker-compose.local.yaml down
docker-compose -f docker-compose.local.yaml up -d
```

### Adicionar Variáveis

1. Adicione no `.env.local`
2. Adicione no `docker-compose.local.yaml` na seção `environment` do serviço
3. Rebuild o serviço

### Desabilitar um Serviço

Comente o serviço no `docker-compose.local.yaml`:

```yaml
# evo-gateway:
#   build:
#     context: ./evo-crm-gateway
#   ...
```

---

## 📚 Documentação Adicional

- **Multi-Tenant:** `MULTI_TENANT_IMPLEMENTATION_COMPLETE.md`
- **Testes:** `GUIA_TESTES_LOCAL.md`
- **API Admin:** `docs/admin-api-endpoints.md`
- **Correções:** `RELATORIO_FINAL_COMPLETO.md`

---

## ✅ Checklist de Verificação

Após subir o sistema, verifique:

- [ ] PostgreSQL está healthy
- [ ] Redis está healthy
- [ ] evo-auth está rodando
- [ ] evo-crm está rodando
- [ ] evo-core está rodando
- [ ] evo-processor está rodando
- [ ] Frontend acessível em http://localhost:5173
- [ ] Login funciona com tonygomes058@gmail.com

---

## 🎯 Próximos Passos

1. Subir o sistema com `docker-compose.local.yaml`
2. Testar login no frontend
3. Verificar funcionalidades
4. Desenvolver e testar mudanças localmente

---

**Criado em:** 2026-04-30  
**Versão:** 1.0  
**Status:** ✅ Pronto para uso
