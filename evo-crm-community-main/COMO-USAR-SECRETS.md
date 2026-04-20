# 🔐 Como Usar os Secrets Gerados

## 📋 Arquivos Criados

1. **`.env.production`** - Arquivo completo com todas as variáveis
2. **`SECRETS-PRODUCTION.txt`** - Apenas os secrets para guardar

---

## ✅ Passo 1: Guardar os Secrets

1. Abrir o arquivo `SECRETS-PRODUCTION.txt`
2. Copiar todo o conteúdo
3. Salvar em um **password manager** (1Password, LastPass, Bitwarden, etc.)
4. **NÃO commitar** este arquivo no Git!

---

## ✅ Passo 2: Configurar Domínios

Editar o arquivo `.env.production` e substituir:

```bash
# Substituir estas linhas:
DOMAIN_FRONTEND=evo.seudominio.com
DOMAIN_AUTH=auth.seudominio.com
DOMAIN_CRM=api.seudominio.com
DOMAIN_CORE=core.seudominio.com
DOMAIN_PROCESSOR=processor.seudominio.com
DOMAIN_BOT=bot.seudominio.com

# Por seus domínios reais, exemplo:
DOMAIN_FRONTEND=evo.minhaempresa.com.br
DOMAIN_AUTH=auth.minhaempresa.com.br
DOMAIN_CRM=api.minhaempresa.com.br
DOMAIN_CORE=core.minhaempresa.com.br
DOMAIN_PROCESSOR=processor.minhaempresa.com.br
DOMAIN_BOT=bot.minhaempresa.com.br
```

---

## ✅ Passo 3: Configurar SMTP

Editar o arquivo `.env.production` e configurar SMTP:

### Opção A: Gmail

```bash
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=macip.com.br
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app-gmail  # Gerar em: https://myaccount.google.com/apppasswords
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
MAILER_SENDER_EMAIL=noreply@macip.com.br
```

### Opção B: SendGrid

```bash
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_DOMAIN=macip.com.br
SMTP_USERNAME=apikey
SMTP_PASSWORD=SG.sua-api-key-aqui
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
MAILER_SENDER_EMAIL=noreply@macip.com.br
```

### Opção C: Mailgun

```bash
SMTP_ADDRESS=smtp.mailgun.org
SMTP_PORT=587
SMTP_DOMAIN=macip.com.br
SMTP_USERNAME=postmaster@mg.macip.com.br
SMTP_PASSWORD=sua-senha-mailgun
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
MAILER_SENDER_EMAIL=noreply@macip.com.br
```

---

## ✅ Passo 4: Configurar Variáveis no EasyPanel

### Para cada serviço, copiar as variáveis correspondentes:

#### Auth Service (evo-auth)

```bash
RAILS_ENV=production
RAILS_MAX_THREADS=5
RAILS_LOG_TO_STDOUT=true

# Database
POSTGRES_HOST=evogo_postgres
POSTGRES_PORT=5432
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=355cbf3375d96724d0ff
POSTGRES_DATABASE=postgres

# Redis
REDIS_URL=redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/1

# Secrets
SECRET_KEY_BASE=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
JWT_SECRET_KEY=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
DOORKEEPER_JWT_SECRET_KEY=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
DOORKEEPER_JWT_ALGORITHM=hs256
DOORKEEPER_JWT_ISS=evo-auth-service
DOORKEEPER_JWT_AUD=[]

# URLs (substituir pelos seus domínios)
FRONTEND_URL=https://evo.macip.com.br

# SMTP (configurar com seus dados)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app
MAILER_SENDER_EMAIL=noreply@macip.com.br

# Outros
MFA_ISSUER=EvoAI
ACTIVE_STORAGE_SERVICE=local
SIDEKIQ_CONCURRENCY=10
ENABLE_ACCOUNT_SIGNUP=true
```

#### CRM Service (evo-crm)

```bash
RAILS_ENV=production
RAILS_MAX_THREADS=5
RAILS_LOG_TO_STDOUT=true

# Database
POSTGRES_HOST=evogo_postgres
POSTGRES_PORT=5432
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=355cbf3375d96724d0ff
POSTGRES_DATABASE=postgres

# Redis
REDIS_URL=redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0

# Secrets
SECRET_KEY_BASE=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
JWT_SECRET_KEY=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
EVOAI_CRM_API_TOKEN=22d16004-2706-4df5-a9e4-31dc35053816
BOT_RUNTIME_SECRET=6c042ef5122814fe0ca8224908957ba39a55dfd1f0c3ae1dd8c4e0a3f5623b50

# URLs internas
EVO_AUTH_SERVICE_URL=http://evo-auth:3001
EVO_AI_CORE_SERVICE_URL=http://evo-core:5555
BOT_RUNTIME_URL=http://evo-bot-runtime:8080
BOT_RUNTIME_POSTBACK_BASE_URL=http://evo-crm:3000

# URLs públicas (substituir pelos seus domínios)
BACKEND_URL=https://api.macip.com.br
FRONTEND_URL=https://evo.macip.com.br
CORS_ORIGINS=https://evo.macip.com.br,https://api.macip.com.br

# Features
DISABLE_TELEMETRY=true
ENABLE_ACCOUNT_SIGNUP=true
ENABLE_PUSH_RELAY_SERVER=true
ENABLE_INBOX_EVENTS=true
LOG_LEVEL=info
```

#### Core Service (evo-core)

```bash
# Database
DB_HOST=evogo_postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=355cbf3375d96724d0ff
DB_NAME=postgres
DB_SSLMODE=disable

# Secrets
JWT_SECRET_KEY=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
JWT_ALGORITHM=HS256
ENCRYPTION_KEY=f4PZ0XgN2fTLbVuVuUDX7zdWWwT7PNyOQSetfRBqSu0

# URLs internas
EVOLUTION_BASE_URL=http://evo-crm:3000
EVO_AUTH_BASE_URL=http://evo-auth:3001
AI_PROCESSOR_URL=http://evo-processor:8000
AI_PROCESSOR_VERSION=v1

# Server
PORT=5555
```

#### Processor Service (evo-processor)

```bash
# Database
POSTGRES_CONNECTION_STRING=postgresql://postgres:355cbf3375d96724d0ff@evogo_postgres:5432/postgres

# Redis
REDIS_HOST=evogo_redis
REDIS_PORT=6379
REDIS_PASSWORD=dpkjzl4kz7riuI5ah7rf
REDIS_DB=0
REDIS_SSL=false

# Secrets
JWT_SECRET_KEY=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
ENCRYPTION_KEY=f4PZ0XgN2fTLbVuVuUDX7zdWWwT7PNyOQSetfRBqSu0
EVOAI_CRM_API_TOKEN=22d16004-2706-4df5-a9e4-31dc35053816

# URLs internas
EVO_AI_CRM_URL=http://evo-crm:3000
CORE_SERVICE_URL=http://evo-core:5555/api/v1
EVO_AUTH_BASE_URL=http://evo-auth:3001

# Server
HOST=0.0.0.0
PORT=8000
AI_ENGINE=adk
```

#### Bot Runtime (evo-bot-runtime)

```bash
LISTEN_ADDR=0.0.0.0:8080
REDIS_URL=redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379
AI_PROCESSOR_URL=http://evo-processor:8000
BOT_RUNTIME_SECRET=6c042ef5122814fe0ca8224908957ba39a55dfd1f0c3ae1dd8c4e0a3f5623b50
AI_CALL_TIMEOUT_SECONDS=30
```

#### Frontend (evo-frontend)

**Build Args (no EasyPanel):**
```
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
```

**Environment Variables:**
```bash
VITE_APP_ENV=production
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_WS_URL=https://api.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
```

---

## ⚠️ IMPORTANTE: Secrets Compartilhados

Estes valores **DEVEM SER IGUAIS** em múltiplos serviços:

| Secret | Serviços | Valor |
|--------|----------|-------|
| `JWT_SECRET_KEY` | Auth, CRM, Core, Processor | `+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==` |
| `ENCRYPTION_KEY` | Core, Processor | `f4PZ0XgN2fTLbVuVuUDX7zdWWwT7PNyOQSetfRBqSu0` |
| `BOT_RUNTIME_SECRET` | CRM, Bot Runtime | `6c042ef5122814fe0ca8224908957ba39a55dfd1f0c3ae1dd8c4e0a3f5623b50` |
| `EVOAI_CRM_API_TOKEN` | CRM, Processor | `22d16004-2706-4df5-a9e4-31dc35053816` |

---

## 🚀 Próximos Passos

1. ✅ Secrets gerados e salvos
2. ⚠️ Configurar domínios no `.env.production`
3. ⚠️ Configurar SMTP no `.env.production`
4. 📖 Seguir o [EASYPANEL-QUICK-START.md](EASYPANEL-QUICK-START.md)
5. ✅ Usar o [CHECKLIST-DEPLOY-EASYPANEL.md](CHECKLIST-DEPLOY-EASYPANEL.md)

---

## 🔒 Segurança

- ✅ Secrets já gerados com alta entropia
- ⚠️ **NÃO commitar** `.env.production` no Git
- ⚠️ **NÃO commitar** `SECRETS-PRODUCTION.txt` no Git
- ✅ Adicionar ao `.gitignore`:
  ```
  .env.production
  SECRETS-PRODUCTION.txt
  ```
- ✅ Guardar em password manager
- ✅ Rotacionar secrets periodicamente (a cada 90 dias)

---

**Última atualização:** 2025-04-20  
**Versão:** 1.0
