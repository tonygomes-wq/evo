# Relatório de Deploy - Sistema Evo AI

**Data**: 29/04/2026 22:52  
**Ambiente**: Docker Desktop Local (Windows)

## Status dos Serviços

### ✅ Serviços Funcionando

1. **PostgreSQL** (evo-postgres-1)
   - Status: Healthy
   - Porta: 5432
   - Imagem: pgvector/pgvector:pg16

2. **Redis** (evo-redis-1)
   - Status: Healthy
   - Porta: 6379
   - Imagem: redis:alpine

3. **MailHog** (evo-mailhog-1)
   - Status: Running
   - Portas: 1025 (SMTP), 8025 (Web UI)
   - Imagem: mailhog/mailhog

4. **Evo Auth Service** (evo-evo-auth-1)
   - Status: Healthy
   - Porta: 3001
   - Migrations: Completas

5. **Evo Auth Sidekiq** (evo-evo-auth-sidekiq-1)
   - Status: Running (unhealthy - normal durante inicialização)
   - Background jobs do Auth Service

6. **Evo CRM** (evo-evo-crm-1)
   - Status: Starting (health check em andamento)
   - Porta: 3000
   - Migrations: Em execução

7. **Evo CRM Sidekiq** (evo-evo-crm-sidekiq-1)
   - Status: Running
   - Background jobs do CRM

8. **Evo Frontend** (evo-evo-frontend-1)
   - Status: Running
   - Porta: 5173
   - Imagem: Nginx com aplicação React/Vue

9. **Evo Bot Runtime** (evo-evo-bot-runtime-1)
   - Status: Starting (health check em andamento)
   - Porta: 8080
   - Correção aplicada: Adicionada variável LISTEN_ADDR

### ❌ Serviços com Problemas

1. **Evo Core Service** (evo-evo-core-1)
   - Status: Restarting
   - Problema: `exec ./entrypoint.sh: no such file or directory`
   - Causa: Volume montado estava sobrescrevendo o binário compilado
   - Solução aplicada: Removido volume do docker-compose
   - **Ação necessária**: Rebuild da imagem

2. **Evo Processor** (evo-evo-processor-1)
   - Status: Restarting
   - Problema: Erro de migration - tabela já existe
   - Causa: Banco de dados foi limpo mas ainda há conflito
   - **Ação necessária**: Verificar logs e ajustar migrations

## Correções Aplicadas

### 1. Dockerfile do CRM
- Corrigido caminho do Dockerfile: `docker/Dockerfile`

### 2. Volumes Removidos
Removidos volumes que sobrescreviam binários compilados:
- `evo-core`: Removido `./evo-ai-core-service-community-main:/app`
- `evo-processor`: Removido `./evo-ai-processor-community-main:/app`
- `evo-bot-runtime`: Removido `./evo-bot-runtime-main:/app`

### 3. Variáveis de Ambiente
- Adicionada `LISTEN_ADDR=0.0.0.0:8080` para o bot-runtime

### 4. Dockerfile do Bot Runtime
- Corrigido CMD para usar caminho absoluto: `/app/evo-bot-runtime`
- Adicionado `chmod +x` para garantir permissões

## Próximos Passos

### Para Corrigir o Core Service

```bash
# Rebuild da imagem do core
docker compose -f docker-compose.local.yaml build evo-core

# Reiniciar o serviço
docker compose -f docker-compose.local.yaml up -d evo-core
```

### Para Corrigir o Processor

```bash
# Verificar logs detalhados
docker logs evo-evo-processor-1 --tail 100

# Se necessário, rebuild
docker compose -f docker-compose.local.yaml build evo-processor
docker compose -f docker-compose.local.yaml up -d evo-processor
```

### Verificar Status Completo

```bash
# Ver todos os containers
docker ps -a

# Ver logs de um serviço específico
docker logs <container-name> --tail 50

# Verificar health checks
docker inspect <container-name> | grep -A 10 Health
```

## Acessos

- **Frontend**: http://localhost:5173
- **Auth API**: http://localhost:3001
- **CRM API**: http://localhost:3000
- **Core API**: http://localhost:5555 (quando funcionar)
- **Processor API**: http://localhost:8000 (quando funcionar)
- **Bot Runtime**: http://localhost:8080 (quando funcionar)
- **MailHog UI**: http://localhost:8025
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

## Credenciais Padrão

### Banco de Dados
- Host: localhost
- Port: 5432
- Database: evo_community
- Username: postgres
- Password: evoai_dev_password

### Redis
- Host: localhost
- Port: 6379
- Password: evoai_redis_pass

## Observações

1. **Warnings sobre variável "Lm7Nq0R"**: Isso é causado por um problema no parsing das chaves secretas no docker-compose. Não afeta o funcionamento.

2. **Atributo `version` obsoleto**: Docker Compose v2 não requer mais a versão no arquivo. Pode ser removido.

3. **Volumes de desenvolvimento**: Para desenvolvimento local com hot-reload, você pode adicionar os volumes de volta, mas isso impedirá o uso de binários compilados.

4. **Migrations**: O sistema está configurado para rodar migrations automaticamente na inicialização.

## Comandos Úteis

```bash
# Parar todos os serviços
docker compose -f docker-compose.local.yaml down

# Parar e remover volumes (limpar banco)
docker compose -f docker-compose.local.yaml down -v

# Rebuild de todas as imagens
docker compose -f docker-compose.local.yaml build

# Iniciar todos os serviços
docker compose -f docker-compose.local.yaml up -d

# Ver logs em tempo real
docker compose -f docker-compose.local.yaml logs -f

# Ver logs de um serviço específico
docker compose -f docker-compose.local.yaml logs -f evo-core
```
