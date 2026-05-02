# Status Atual dos Serviços - 02/05/2026 09:35

## ✅ Serviços Funcionando (7/11)

| Serviço | Status | Porta | Observação |
|---------|--------|-------|------------|
| **postgres** | ✅ Healthy | 5432 | Funcionando perfeitamente |
| **redis** | ✅ Healthy | 6379 | Funcionando perfeitamente |
| **mailhog** | ✅ Running | 1025, 8025 | Funcionando perfeitamente |
| **evo-auth** | ✅ Healthy | 3001 | Funcionando perfeitamente |
| **evo-frontend** | ✅ Running | 5173 | Funcionando perfeitamente |
| **evo-crm** | ✅ Starting | 3000 | Health check em andamento, mas funcionando |
| **evo-crm-sidekiq** | ✅ Running | - | Funcionando perfeitamente |

## ❌ Serviços com Problemas (4/11)

### 1. evo-core (CRÍTICO)
**Status**: Restarting  
**Erro**: `Environment variable PORT is required`

**Problema**: Falta a variável de ambiente `PORT`

**Solução**:
```yaml
# Adicionar no docker-compose.local.yaml na seção evo-core:
environment:
  PORT: "5555"
```

---

### 2. evo-processor (CRÍTICO)
**Status**: Restarting  
**Erro**: `DuplicateTableError: relation "evo_agent_processor_execution_metrics" already exists`

**Problema**: Tabela já existe no banco de dados (migration duplicada)

**Solução**: Limpar o banco e reiniciar
```bash
docker compose -f docker-compose.local.yaml down -v
docker compose -f docker-compose.local.yaml up -d
```

---

### 3. evo-crm (PARCIAL)
**Status**: Health check starting  
**Erro**: `PG::DuplicateColumn: column "sentiment_offensive" already exists`

**Problema**: Coluna já existe no banco (migration duplicada)

**Observação**: O CRM está rodando mas com erro de migration. Pode funcionar parcialmente.

**Solução**: Limpar o banco e reiniciar (mesma solução do processor)

---

### 4. evo-bot-runtime (MENOR)
**Status**: Unhealthy  
**Erro**: `redis: connection pool: failed to dial`

**Problema**: Tentando conectar ao Redis no IP errado (172.18.0.4 ao invés do nome do serviço)

**Observação**: O serviço está rodando, mas o health check falha. Pode estar funcionando parcialmente.

**Solução**: Verificar se a variável REDIS_URL está correta

---

### 5. evo-auth-sidekiq (MENOR)
**Status**: Unhealthy  
**Observação**: É normal durante inicialização. Geralmente se resolve sozinho.

---

## 🔧 Correções Necessárias

### Correção Imediata - Evo Core

Adicionar a variável PORT no docker-compose.local.yaml:

```yaml
evo-core:
  build:
    context: ./evo-ai-core-service-community-main
    dockerfile: Dockerfile
  restart: unless-stopped
  ports:
    - "5555:5555"
  environment:
    DB_HOST: postgres
    DB_PORT: "5432"
    DB_USER: postgres
    DB_PASSWORD: evoai_dev_password
    DB_NAME: evo_community
    DB_SSLMODE: disable
    PORT: "5555"  # <-- ADICIONAR ESTA LINHA
    SECRET_KEY_BASE: a_i9F-k2-Lm7Nq0R-sT4uW6xZ8bD1eG3hJ5oP7rV9yAcE2fH4jM6pS8vX0zB3dK5nQ7tU9wY1
    # ... resto das variáveis
```

### Correção Completa - Todos os Problemas

Para resolver TODOS os problemas de uma vez:

```bash
# 1. Parar todos os serviços e limpar volumes
docker compose -f docker-compose.local.yaml down -v

# 2. Adicionar PORT: "5555" no evo-core (editar docker-compose.local.yaml)

# 3. Iniciar novamente
docker compose -f docker-compose.local.yaml up -d

# 4. Acompanhar os logs
docker compose -f docker-compose.local.yaml logs -f
```

## 📊 Resumo

**Funcionando**: 7/11 serviços (64%)  
**Com Problemas**: 4/11 serviços (36%)

**Problemas Principais**:
1. ✅ **Fácil de resolver**: Falta variável PORT no evo-core
2. ⚠️ **Requer limpeza**: Migrations duplicadas no banco (processor e crm)
3. ℹ️ **Menor**: Problemas de health check (bot-runtime e auth-sidekiq)

**Tempo Estimado para Correção**: 5-10 minutos

## 🚀 Ação Recomendada

Execute os seguintes comandos na ordem:

```bash
# 1. Parar tudo
docker compose -f docker-compose.local.yaml down -v

# 2. Editar docker-compose.local.yaml e adicionar PORT: "5555" no evo-core

# 3. Iniciar tudo novamente
docker compose -f docker-compose.local.yaml up -d

# 4. Aguardar 5 minutos e verificar
docker ps
```

Após isso, todos os 11 serviços devem estar funcionando corretamente.

## 🌐 Acessos Disponíveis Agora

Estes serviços já estão acessíveis:

- ✅ **Frontend**: http://localhost:5173
- ✅ **Auth API**: http://localhost:3001
- ✅ **CRM API**: http://localhost:3000 (parcial)
- ✅ **MailHog UI**: http://localhost:8025
- ❌ **Core API**: http://localhost:5555 (não disponível - falta PORT)
- ❌ **Processor API**: http://localhost:8000 (não disponível - erro migration)
- ⚠️ **Bot Runtime**: http://localhost:8080 (rodando mas unhealthy)
