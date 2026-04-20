# 🚀 EasyPanel Quick Start Guide - EVO CRM Community

## Guia Rápido de Deploy (30 minutos)

Este é um guia resumido para deploy rápido. Para detalhes completos, consulte `DOCUMENTACAO-LOCAL-EASYPANEL.md`.

---

## ⚡ Pré-requisitos

- [ ] Conta no EasyPanel
- [ ] PostgreSQL com pgvector instalado
- [ ] Domínios configurados (6 subdomínios)
- [ ] SMTP configurado (Gmail, SendGrid, etc.)

---

## 📝 Passo 1: Gerar Secrets (5 min)

```bash
# JWT_SECRET_KEY e SECRET_KEY_BASE (usar o mesmo valor)
openssl rand -base64 64 | tr -d '\n'
# Copiar e salvar como: JWT_SECRET_KEY

# ENCRYPTION_KEY
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
# Copiar e salvar como: ENCRYPTION_KEY

# BOT_RUNTIME_SECRET
openssl rand -hex 32
# Copiar e salvar como: BOT_RUNTIME_SECRET

# EVOAI_CRM_API_TOKEN
uuidgen | tr '[:upper:]' '[:lower:]'
# Copiar e salvar como: EVOAI_CRM_API_TOKEN

# DOORKEEPER_JWT_SECRET_KEY (pode ser igual ao JWT_SECRET_KEY)
# Usar o mesmo valor do JWT_SECRET_KEY

# REDIS_PASSWORD
openssl rand -base64 32 | tr -d '\n'
# Copiar e salvar como: REDIS_PASSWORD
```

**Salvar todos em um arquivo seguro!**

---

## 📝 Passo 2: Criar Redis no EasyPanel (2 min)

1. Criar novo serviço: **Redis**
2. Nome: `redis`
3. Versão: `alpine`
4. Senha: usar `REDIS_PASSWORD` gerado acima
5. Persistência: ✅ Habilitado
6. Volume: 2 GB
7. Recursos: 0.5 CPU, 512 MB RAM

---

## 📝 Passo 3: Preparar PostgreSQL (3 min)

```sql
-- Conectar ao PostgreSQL existente
CREATE DATABASE evo_community;

\c evo_community

-- Habilitar extensões
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

---

## 📝 Passo 4: Deploy dos Serviços (20 min)

### 4.1 Auth Service

**Criar App:**
- Nome: `evo-auth`
- Porta: `3001`
- Domínio: `auth.seudominio.com`
- Source: GitHub `evo-auth-service-community`

**Variáveis Essenciais:**
```env
RAILS_ENV=production
POSTGRES_HOST=seu-postgres-host
POSTGRES_PORT=5432
POSTGRES_USERNAME=seu-usuario
POSTGRES_PASSWORD=sua-senha
POSTGRES_DATABASE=evo_community
REDIS_URL=redis://:REDIS_PASSWORD@redis:6379/1
SECRET_KEY_BASE=JWT_SECRET_KEY
JWT_SECRET_KEY=JWT_SECRET_KEY
DOORKEEPER_JWT_SECRET_KEY=JWT_SECRET_KEY
DOORKEEPER_JWT_ALGORITHM=hs256
DOORKEEPER_JWT_ISS=evo-auth-service
FRONTEND_URL=https://evo.seudominio.com
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app
MAILER_SENDER_EMAIL=noreply@seudominio.com
```

**Comando:**
```bash
bundle install && bundle exec rails db:prepare && bundle exec rails db:seed && bundle exec rails s -p 3001 -b 0.0.0.0
```

**Health Check:** `/health` porta `3001`

---

### 4.2 Auth Sidekiq

**Criar App:**
- Nome: `evo-auth-sidekiq`
- Sem porta (worker)
- Source: Mesmo do auth

**Variáveis:** Mesmas do auth

**Comando:**
```bash
bundle install && bundle exec sidekiq
```

---

### 4.3 CRM Service

**Criar App:**
- Nome: `evo-crm`
- Porta: `3000`
- Domínio: `api.seudominio.com`
- Source: GitHub `evo-ai-crm-community`
- Dockerfile: `docker/Dockerfile`

**Variáveis Essenciais:**
```env
RAILS_ENV=production
POSTGRES_HOST=seu-postgres-host
POSTGRES_PORT=5432
POSTGRES_USERNAME=seu-usuario
POSTGRES_PASSWORD=sua-senha
POSTGRES_DATABASE=evo_community
REDIS_URL=redis://:REDIS_PASSWORD@redis:6379/0
SECRET_KEY_BASE=JWT_SECRET_KEY
JWT_SECRET_KEY=JWT_SECRET_KEY
EVOAI_CRM_API_TOKEN=EVOAI_CRM_API_TOKEN
EVO_AUTH_SERVICE_URL=http://evo-auth:3001
EVO_AI_CORE_SERVICE_URL=http://evo-core:5555
BOT_RUNTIME_URL=http://evo-bot-runtime:8080
BOT_RUNTIME_SECRET=BOT_RUNTIME_SECRET
BOT_RUNTIME_POSTBACK_BASE_URL=http://evo-crm:3000
BACKEND_URL=https://api.seudominio.com
FRONTEND_URL=https://evo.seudominio.com
CORS_ORIGINS=https://evo.seudominio.com,https://api.seudominio.com
```

**Comando:**
```bash
bundle exec rails db:prepare && bundle exec rails s -p 3000 -b 0.0.0.0
```

**Health Check:** `/health/live` porta `3000`

---

### 4.4 CRM Sidekiq

**Criar App:**
- Nome: `evo-crm-sidekiq`
- Sem porta (worker)
- Source: Mesmo do CRM

**Variáveis:** Mesmas do CRM

**Comando:**
```bash
bundle exec sidekiq -C config/sidekiq.yml
```

---

### 4.5 Core Service

**Criar App:**
- Nome: `evo-core`
- Porta: `5555`
- Domínio: `core.seudominio.com`
- Source: GitHub `evo-ai-core-service-community`

**Variáveis Essenciais:**
```env
DB_HOST=seu-postgres-host
DB_PORT=5432
DB_USER=seu-usuario
DB_PASSWORD=sua-senha
DB_NAME=evo_community
DB_SSLMODE=disable
JWT_SECRET_KEY=JWT_SECRET_KEY
JWT_ALGORITHM=HS256
ENCRYPTION_KEY=ENCRYPTION_KEY
EVOLUTION_BASE_URL=http://evo-crm:3000
EVO_AUTH_BASE_URL=http://evo-auth:3001
AI_PROCESSOR_URL=http://evo-processor:8000
AI_PROCESSOR_VERSION=v1
PORT=5555
```

**Health Check:** `/health` porta `5555`

---

### 4.6 Processor Service

**Criar App:**
- Nome: `evo-processor`
- Porta: `8000`
- Domínio: `processor.seudominio.com`
- Source: GitHub `evo-ai-processor-community`

**Variáveis Essenciais:**
```env
POSTGRES_CONNECTION_STRING=postgresql://usuario:senha@host:5432/evo_community
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=REDIS_PASSWORD
REDIS_DB=0
REDIS_SSL=false
JWT_SECRET_KEY=JWT_SECRET_KEY
ENCRYPTION_KEY=ENCRYPTION_KEY
EVOAI_CRM_API_TOKEN=EVOAI_CRM_API_TOKEN
EVO_AI_CRM_URL=http://evo-crm:3000
CORE_SERVICE_URL=http://evo-core:5555/api/v1
EVO_AUTH_BASE_URL=http://evo-auth:3001
HOST=0.0.0.0
PORT=8000
AI_ENGINE=adk
```

**Health Check:** `/health` porta `8000`

---

### 4.7 Bot Runtime

**Criar App:**
- Nome: `evo-bot-runtime`
- Porta: `8080`
- Domínio: `bot.seudominio.com` (opcional)
- Source: GitHub `evo-bot-runtime`

**Variáveis Essenciais:**
```env
LISTEN_ADDR=0.0.0.0:8080
REDIS_URL=redis://:REDIS_PASSWORD@redis:6379
AI_PROCESSOR_URL=http://evo-processor:8000
BOT_RUNTIME_SECRET=BOT_RUNTIME_SECRET
AI_CALL_TIMEOUT_SECONDS=30
```

**Health Check:** `/health` porta `8080`

---

### 4.8 Frontend

**Criar App:**
- Nome: `evo-frontend`
- Porta: `80`
- Domínio: `evo.seudominio.com`
- Source: GitHub `evo-ai-frontend-community`

**Build Args (IMPORTANTE):**
```
VITE_API_URL=https://api.seudominio.com
VITE_AUTH_API_URL=https://auth.seudominio.com
VITE_EVOAI_API_URL=https://core.seudominio.com
VITE_AGENT_PROCESSOR_URL=https://processor.seudominio.com
```

**Variáveis Runtime:**
```env
VITE_APP_ENV=production
VITE_API_URL=https://api.seudominio.com
VITE_AUTH_API_URL=https://auth.seudominio.com
VITE_WS_URL=https://api.seudominio.com
VITE_EVOAI_API_URL=https://core.seudominio.com
VITE_AGENT_PROCESSOR_URL=https://processor.seudominio.com
```

**Health Check:** `/health` porta `80`

---

## 📝 Passo 5: Verificação (5 min)

### 5.1 Testar Health Checks

```bash
curl https://auth.seudominio.com/health
curl https://api.seudominio.com/health/live
curl https://core.seudominio.com/health
curl https://processor.seudominio.com/health
curl https://bot.seudominio.com/health
```

### 5.2 Testar Login

1. Acessar `https://evo.seudominio.com`
2. Login:
   - Email: `support@evo-auth-service-community.com`
   - Senha: `Password@123`

---

## 🎯 Recursos por Serviço

| Serviço | CPU | RAM | Storage |
|---------|-----|-----|---------|
| Redis | 0.5 | 512 MB | 2 GB |
| Auth | 1 | 1 GB | 5 GB |
| Auth Sidekiq | 0.5 | 512 MB | - |
| CRM | 2 | 2 GB | 10 GB |
| CRM Sidekiq | 1 | 1 GB | - |
| Core | 1 | 1 GB | 2 GB |
| Processor | 2 | 2 GB | 5 GB |
| Bot Runtime | 1 | 512 MB | - |
| Frontend | 0.5 | 256 MB | - |
| **TOTAL** | **9.5** | **9 GB** | **24 GB** |

---

## 🔥 Troubleshooting Rápido

### Serviço não inicia
```bash
# Ver logs no EasyPanel
# Verificar variáveis de ambiente
# Testar conexão com banco/redis
```

### Login não funciona
```bash
# No container evo-auth
bundle exec rails db:seed
```

### Frontend não carrega
```bash
# Rebuild com build args corretos
# Verificar CORS no backend
```

### Sidekiq não processa
```bash
# Verificar se worker está rodando
# Testar conexão Redis
```

---

## 📚 Documentação Completa

Para detalhes completos, troubleshooting avançado e configurações opcionais, consulte:
- `DOCUMENTACAO-LOCAL-EASYPANEL.md`

---

## ✅ Checklist Final

- [ ] Todos os serviços healthy
- [ ] Login funcionando
- [ ] Conversa criada com sucesso
- [ ] Agente respondendo
- [ ] Jobs processando
- [ ] WebSocket conectando
- [ ] Backup configurado

---

**Tempo total estimado:** 30-40 minutos  
**Dificuldade:** Intermediária  
**Suporte:** Consultar documentação completa para troubleshooting
