# 🔗 Configuração GitHub → EasyPanel

**Repositório:** https://github.com/tonygomes-wq/evo

Este guia mostra exatamente como configurar cada serviço no EasyPanel apontando para o GitHub.

---

## 📋 Estrutura do Repositório GitHub

```
https://github.com/tonygomes-wq/evo/
├── evo-auth-service-community-main/
├── evo-ai-core-service-community-main/
├── evo-ai-processor-community-main/
├── evo-ai-frontend-community-main/
├── evo-bot-runtime-main/
└── evo-crm-community-main/
    ├── evo-auth-service-community/
    ├── evo-ai-crm-community/
    ├── evo-ai-core-service-community/
    ├── evo-ai-processor-community/
    ├── evo-bot-runtime/
    └── evo-ai-frontend-community/
```

---

## 🚀 Configuração por Serviço

### 1️⃣ Auth Service (evo-auth)

**No EasyPanel:**

1. Criar novo App → **From Source**
2. Configurar Source:
   ```
   Repository: https://github.com/tonygomes-wq/evo
   Branch: main
   Build Path: /evo-auth-service-community-main
   ```

3. Configurar Build:
   ```
   Build Type: Dockerfile
   Dockerfile Path: Dockerfile
   Build Context: /evo-auth-service-community-main
   ```

4. Configurar App:
   ```
   Name: evo-auth
   Port: 3001
   Domain: auth.seudominio.com
   ```

5. Adicionar Environment Variables:
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
   
   # URLs
   FRONTEND_URL=https://evo.seudominio.com
   
   # SMTP (configurar com seus dados)
   SMTP_ADDRESS=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USERNAME=seu-email@gmail.com
   SMTP_PASSWORD=sua-senha-app
   MAILER_SENDER_EMAIL=noreply@seudominio.com
   SMTP_AUTHENTICATION=plain
   SMTP_ENABLE_STARTTLS_AUTO=true
   
   # Outros
   MFA_ISSUER=EvoAI
   ACTIVE_STORAGE_SERVICE=local
   SIDEKIQ_CONCURRENCY=10
   ENABLE_ACCOUNT_SIGNUP=true
   ```

6. Configurar Command (opcional):
   ```bash
   bundle install && bundle exec rails db:prepare && bundle exec rails db:seed && bundle exec rails s -p 3001 -b 0.0.0.0
   ```

7. Health Check:
   ```
   Path: /health
   Port: 3001
   ```

---

### 2️⃣ Auth Sidekiq (evo-auth-sidekiq)

**No EasyPanel:**

1. Criar novo App → **From Source**
2. Configurar Source:
   ```
   Repository: https://github.com/tonygomes-wq/evo
   Branch: main
   Build Path: /evo-auth-service-community-main
   ```

3. Configurar Build:
   ```
   Build Type: Dockerfile
   Dockerfile Path: Dockerfile
   Build Context: /evo-auth-service-community-main
   ```

4. Configurar App:
   ```
   Name: evo-auth-sidekiq
   Port: (deixar vazio - é um worker)
   ```

5. Environment Variables: **Mesmas do Auth Service**

6. Configurar Command:
   ```bash
   bundle install && bundle exec sidekiq
   ```

---

### 3️⃣ CRM Service (evo-crm)

**No EasyPanel:**

1. Criar novo App → **From Source**
2. Configurar Source:
   ```
   Repository: https://github.com/tonygomes-wq/evo
   Branch: main
   Build Path: /evo-crm-community-main/evo-ai-crm-community
   ```

3. Configurar Build:
   ```
   Build Type: Dockerfile
   Dockerfile Path: docker/Dockerfile
   Build Context: /evo-crm-community-main/evo-ai-crm-community
   ```

4. Configurar App:
   ```
   Name: evo-crm
   Port: 3000
   Domain: api.seudominio.com
   ```

5. Adicionar Environment Variables:
   ```bash
   RAILS_ENV=production
   RAILS_MAX_THREADS=5
   RAILS_LOG_TO_STDOUT=true
   RAILS_SERVE_STATIC_FILES=false
   
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
   
   # URLs públicas
   BACKEND_URL=https://api.seudominio.com
   FRONTEND_URL=https://evo.seudominio.com
   CORS_ORIGINS=https://evo.seudominio.com,https://api.seudominio.com
   
   # Features
   DISABLE_TELEMETRY=true
   ENABLE_ACCOUNT_SIGNUP=true
   ENABLE_PUSH_RELAY_SERVER=true
   ENABLE_INBOX_EVENTS=true
   LOG_LEVEL=info
   LOG_SIZE=500
   FB_VERIFY_TOKEN=evolution
   FACEBOOK_API_VERSION=v23.0
   ```

6. Configurar Command:
   ```bash
   bundle exec rails db:prepare && bundle exec rails s -p 3000 -b 0.0.0.0
   ```

7. Health Check:
   ```
   Path: /health/live
   Port: 3000
   ```

---

### 4️⃣ CRM Sidekiq (evo-crm-sidekiq)

**No EasyPanel:**

1. Criar novo App → **From Source**
2. Configurar Source:
   ```
   Repository: https://github.com/tonygomes-wq/evo
   Branch: main
   Build Path: /evo-crm-community-main/evo-ai-crm-community
   ```

3. Configurar Build:
   ```
   Build Type: Dockerfile
   Dockerfile Path: docker/Dockerfile
   Build Context: /evo-crm-community-main/evo-ai-crm-community
   ```

4. Configurar App:
   ```
   Name: evo-crm-sidekiq
   Port: (deixar vazio - é um worker)
   ```

5. Environment Variables: **Mesmas do CRM Service**

6. Configurar Command:
   ```bash
   bundle exec sidekiq -C config/sidekiq.yml
   ```

---

### 5️⃣ Core Service (evo-core)

**No EasyPanel:**

1. Criar novo App → **From Source**
2. Configurar Source:
   ```
   Repository: https://github.com/tonygomes-wq/evo
   Branch: main
   Build Path: /evo-ai-core-service-community-main
   ```

3. Configurar Build:
   ```
   Build Type: Dockerfile
   Dockerfile Path: Dockerfile
   Build Context: /evo-ai-core-service-community-main
   ```

4. Configurar App:
   ```
   Name: evo-core
   Port: 5555
   Domain: core.seudominio.com
   ```

5. Adicionar Environment Variables:
   ```bash
   # Database
   DB_HOST=evogo_postgres
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=355cbf3375d96724d0ff
   DB_NAME=postgres
   DB_SSLMODE=disable
   
   # Connection pool
   DB_MAX_IDLE_CONNS=10
   DB_MAX_OPEN_CONNS=100
   DB_CONN_MAX_LIFETIME=1h
   DB_CONN_MAX_IDLE_TIME=30m
   
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

6. Health Check:
   ```
   Path: /health
   Port: 5555
   ```

---

### 6️⃣ Processor Service (evo-processor)

**No EasyPanel:**

1. Criar novo App → **From Source**
2. Configurar Source:
   ```
   Repository: https://github.com/tonygomes-wq/evo
   Branch: main
   Build Path: /evo-ai-processor-community-main
   ```

3. Configurar Build:
   ```
   Build Type: Dockerfile
   Dockerfile Path: Dockerfile
   Build Context: /evo-ai-processor-community-main
   ```

4. Configurar App:
   ```
   Name: evo-processor
   Port: 8000
   Domain: processor.seudominio.com
   ```

5. Adicionar Environment Variables:
   ```bash
   # API
   API_TITLE=Agent Processor Community
   API_DESCRIPTION=Agent Processor Community for Evo AI
   API_VERSION=1.0.0
   API_URL=https://processor.seudominio.com
   APP_URL=https://processor.seudominio.com
   
   # Organization
   ORGANIZATION_NAME=Evo AI
   ORGANIZATION_URL=https://seudominio.com
   
   # Database
   POSTGRES_CONNECTION_STRING=postgresql://postgres:355cbf3375d96724d0ff@evogo_postgres:5432/postgres
   
   # Redis
   REDIS_HOST=evogo_redis
   REDIS_PORT=6379
   REDIS_PASSWORD=dpkjzl4kz7riuI5ah7rf
   REDIS_DB=0
   REDIS_SSL=false
   REDIS_KEY_PREFIX=a2a:
   REDIS_TTL=3600
   
   # Secrets
   JWT_SECRET_KEY=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
   JWT_ALGORITHM=HS256
   ENCRYPTION_KEY=f4PZ0XgN2fTLbVuVuUDX7zdWWwT7PNyOQSetfRBqSu0
   EVOAI_CRM_API_TOKEN=22d16004-2706-4df5-a9e4-31dc35053816
   
   # URLs internas
   EVO_AI_CRM_URL=http://evo-crm:3000
   CORE_SERVICE_URL=http://evo-core:5555/api/v1
   EVO_AUTH_BASE_URL=http://evo-auth:3001
   EVOLUTION_BASE_URL=http://evo-crm:3000
   EVO_CORE_BASE_URL=http://evo-core:5555
   
   # Server
   HOST=0.0.0.0
   PORT=8000
   DEBUG=false
   
   # AI Engine
   AI_ENGINE=adk
   
   # Cache
   TOOLS_CACHE_ENABLED=true
   TOOLS_CACHE_TTL=3600
   
   # Logging
   LOG_LEVEL=INFO
   
   # Memory
   MEMORY_SERVICE_TYPE=http
   MEMORY_ENABLED=true
   MEMORY_MAX_RESULTS=10
   
   # Artifact
   ARTIFACT_SERVICE_TYPE=in_memory
   ```

6. Health Check:
   ```
   Path: /health
   Port: 8000
   ```

---

### 7️⃣ Bot Runtime (evo-bot-runtime)

**No EasyPanel:**

1. Criar novo App → **From Source**
2. Configurar Source:
   ```
   Repository: https://github.com/tonygomes-wq/evo
   Branch: main
   Build Path: /evo-bot-runtime-main
   ```

3. Configurar Build:
   ```
   Build Type: Dockerfile
   Dockerfile Path: Dockerfile
   Build Context: /evo-bot-runtime-main
   ```

4. Configurar App:
   ```
   Name: evo-bot-runtime
   Port: 8080
   Domain: bot.seudominio.com (opcional)
   ```

5. Adicionar Environment Variables:
   ```bash
   LISTEN_ADDR=0.0.0.0:8080
   REDIS_URL=redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379
   AI_PROCESSOR_URL=http://evo-processor:8000
   BOT_RUNTIME_SECRET=6c042ef5122814fe0ca8224908957ba39a55dfd1f0c3ae1dd8c4e0a3f5623b50
   AI_CALL_TIMEOUT_SECONDS=30
   ```

6. Health Check:
   ```
   Path: /health
   Port: 8080
   ```

---

### 8️⃣ Frontend (evo-frontend)

**No EasyPanel:**

1. Criar novo App → **From Source**
2. Configurar Source:
   ```
   Repository: https://github.com/tonygomes-wq/evo
   Branch: main
   Build Path: /evo-ai-frontend-community-main
   ```

3. Configurar Build:
   ```
   Build Type: Dockerfile
   Dockerfile Path: Dockerfile
   Build Context: /evo-ai-frontend-community-main
   ```

4. **IMPORTANTE: Configurar Build Args** (antes do build):
   ```
   VITE_API_URL=https://api.seudominio.com
   VITE_AUTH_API_URL=https://auth.seudominio.com
   VITE_EVOAI_API_URL=https://core.seudominio.com
   VITE_AGENT_PROCESSOR_URL=https://processor.seudominio.com
   ```

5. Configurar App:
   ```
   Name: evo-frontend
   Port: 80
   Domain: evo.seudominio.com
   ```

6. Adicionar Environment Variables (runtime):
   ```bash
   VITE_APP_ENV=production
   VITE_API_URL=https://api.seudominio.com
   VITE_AUTH_API_URL=https://auth.seudominio.com
   VITE_WS_URL=https://api.seudominio.com
   VITE_EVOAI_API_URL=https://core.seudominio.com
   VITE_AGENT_PROCESSOR_URL=https://processor.seudominio.com
   VITE_TINYMCE_API_KEY=no-api-key
   ```

7. Health Check:
   ```
   Path: /health
   Port: 80
   ```

---

## 📊 Resumo de Configuração

| Serviço | Repository Path | Dockerfile Path | Port |
|---------|----------------|-----------------|------|
| evo-auth | `/evo-auth-service-community-main` | `Dockerfile` | 3001 |
| evo-auth-sidekiq | `/evo-auth-service-community-main` | `Dockerfile` | - |
| evo-crm | `/evo-crm-community-main/evo-ai-crm-community` | `docker/Dockerfile` | 3000 |
| evo-crm-sidekiq | `/evo-crm-community-main/evo-ai-crm-community` | `docker/Dockerfile` | - |
| evo-core | `/evo-ai-core-service-community-main` | `Dockerfile` | 5555 |
| evo-processor | `/evo-ai-processor-community-main` | `Dockerfile` | 8000 |
| evo-bot-runtime | `/evo-bot-runtime-main` | `Dockerfile` | 8080 |
| evo-frontend | `/evo-ai-frontend-community-main` | `Dockerfile` | 80 |

---

## ⚠️ Pontos Importantes

### 1. Build Path vs Build Context
- **Build Path**: Onde o EasyPanel vai procurar o código
- **Build Context**: Contexto para o Docker build (geralmente o mesmo)

### 2. Frontend Build Args
- **CRÍTICO**: Build Args devem ser configurados **ANTES** do build
- Se errar, precisa fazer rebuild completo
- São URLs públicas (HTTPS)

### 3. URLs Internas vs Públicas
- **Internas**: `http://service-name:port` (comunicação entre serviços)
- **Públicas**: `https://dominio.com` (acesso externo)

### 4. Ordem de Deploy
```
1. evo-auth
2. evo-auth-sidekiq
3. evo-crm
4. evo-crm-sidekiq
5. evo-core
6. evo-processor
7. evo-bot-runtime
8. evo-frontend
```

---

## 🔧 Troubleshooting

### Build falha com "context not found"
- Verificar se o **Build Path** está correto
- Verificar se o **Dockerfile Path** está correto
- Verificar se o repositório foi clonado corretamente

### Serviço não conecta ao PostgreSQL/Redis
- Verificar se os nomes dos hosts estão corretos:
  - PostgreSQL: `evogo_postgres`
  - Redis: `evogo_redis`
- Verificar se as senhas estão corretas

### Frontend não carrega APIs
- Verificar se os **Build Args** foram configurados
- Verificar se as URLs públicas estão corretas (HTTPS)
- Fazer rebuild se necessário

---

## 📞 Próximos Passos

1. ✅ Configurar cada serviço seguindo este guia
2. ✅ Aguardar build de cada serviço
3. ✅ Verificar health checks
4. ✅ Executar seeds (Auth primeiro, depois CRM)
5. ✅ Testar login no frontend

---

**Repositório:** https://github.com/tonygomes-wq/evo  
**Última atualização:** 2025-04-20  
**Versão:** 1.0
