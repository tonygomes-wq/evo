# EVO CRM Community - Documentacao de subida local e plano EasyPanel

## 📋 Resumo Executivo

**Status:** ✅ **VIÁVEL** para deploy no EasyPanel

**Infraestrutura necessária:**
- ✅ PostgreSQL com pgvector (já disponível)
- ⚠️ Redis (precisa criar)
- 📦 8 aplicações (6 serviços + 2 workers Sidekiq)

**Ordem de deploy crítica:**
1. Redis
2. Auth Service + Auth Sidekiq
3. CRM Service + CRM Sidekiq
4. Core Service
5. Processor Service
6. Bot Runtime
7. Frontend

**Recursos estimados:**
- CPU total: ~9 cores
- RAM total: ~9 GB
- Storage: ~30 GB

**Tempo estimado de setup:** 4-6 horas

**Domínios necessários:**
- `auth.seudominio.com` (Auth Service)
- `api.seudominio.com` (CRM Service)
- `core.seudominio.com` (Core Service)
- `processor.seudominio.com` (Processor Service)
- `evo.seudominio.com` (Frontend)
- `bot.seudominio.com` (Bot Runtime - opcional, pode ser interno)

---

## 1) Objetivo

Este documento registra:

- o que foi feito para subir o projeto localmente no Windows com Docker Desktop;
- os ajustes tecnicos aplicados para contornar erros de bootstrap;
- **um plano COMPLETO e DETALHADO** para publicar a stack no EasyPanel com foco em estabilidade e operacao.

---

## 2) Contexto da stack

Servicos principais da stack no `docker-compose.yml`:

- `postgres` (porta 5432)
- `redis` (porta 6379)
- `mailhog` (portas 1025 e 8025)
- `evo-auth` (porta 3001)
- `evo-crm` (porta 3000)
- `evo-core` (porta 5555)
- `evo-processor` (porta 8000)
- `evo-bot-runtime` (porta 8080)
- `evo-frontend` (porta 5173)

---

## 3) O que foi feito para subir localmente

### 3.1 Preparacao inicial

1. Confirmada a estrutura do projeto e o compose principal em:
   - `docker-compose.yml`
2. Criado arquivo de ambiente local:
   - copiado `.env.example` para `.env`.

### 3.2 Correcao de repositorios vazios na pasta raiz

Foi identificado que as pastas de servicos dentro de `evo-crm-community-main` estavam vazias (sem codigo), o que impedia o build do Docker.

Acao executada:

- clonagem dos repositorios dos servicos diretamente nas pastas esperadas pelo compose:
  - `evo-auth-service-community`
  - `evo-ai-crm-community`
  - `evo-ai-frontend-community`
  - `evo-ai-processor-community`
  - `evo-ai-core-service-community`
  - `evo-bot-runtime`

### 3.3 Correcao de variaveis no `.env`

Foi detectado warning recorrente de interpolacao no Docker Compose por causa de caractere `$` em secrets.

Ajustes aplicados:

- valores de `SECRET_KEY_BASE`, `JWT_SECRET_KEY` e `DOORKEEPER_JWT_SECRET_KEY` ajustados para strings sem `$`.

### 3.4 Correcao de line ending em scripts shell

No Windows, varios scripts `.sh` estavam com CRLF e causavam erros como:

- `exec ...: no such file or directory`

Acao executada:

- normalizacao para LF de scripts nos servicos:
  - CRM
  - Core
  - Auth
  - Processor
  - Bot Runtime
  - Frontend

### 3.5 Correcao de healthcheck no Core

Foi identificado que o endpoint configurado no compose para o `evo-core` retornava 404.

Ajuste aplicado em `docker-compose.yml`:

- de `http://localhost:5555/api/v1/health`
- para `http://localhost:5555/health`

### 3.6 Bootstrap de banco e migrations

Durante o bootstrap houve inconsistencias de migrations:

- no `evo-processor`: erro de `DuplicateTableError` em migration Alembic;
- no `evo-crm`: pending migrations e conflitos de colunas em parte da sequencia.

Acoes de contorno aplicadas para ambiente local:

- `docker compose down -v --remove-orphans` para reset de volumes;
- ajuste de `alembic_version` no PostgreSQL para alinhar estado inicial do processor;
- execucao de `rails db:prepare` no container do CRM;
- insercao de versoes em `schema_migrations` para alinhar o estado esperado no bootstrap local.

---

## 4) Resultado atual (ambiente local)

Stack funcional com endpoints principais acessiveis:

- Frontend: `http://localhost:5173`
- CRM: `http://localhost:3000`
- Auth: `http://localhost:3001`
- Core: `http://localhost:5555`
- Processor: `http://localhost:8000`
- Mailhog: `http://localhost:8025`

Observacao:

- `evo-auth-sidekiq` pode aparecer como `unhealthy` em alguns ciclos de healthcheck, mas em geral o processo esta ativo.

---

## 5) Comandos operacionais locais

Na raiz `evo-crm-community-main`:

- subir stack:
  - `docker compose up -d`
- verificar status:
  - `docker compose ps`
- acompanhar logs:
  - `docker compose logs -f`
- reiniciar servico especifico:
  - `docker compose restart <servico>`
- parar stack:
  - `docker compose down`
- reset completo (dados locais):
  - `docker compose down -v --remove-orphans`

---

## 6) Plano de Deploy no EasyPanel

### ✅ Viabilidade Técnica

**CONCLUSÃO: É TOTALMENTE VIÁVEL** subir todos os serviços no EasyPanel!

**Requisitos atendidos:**
- ✅ PostgreSQL com pgvector já instalado
- ✅ Todos os serviços possuem Dockerfile
- ✅ Healthchecks implementados em todos os serviços
- ✅ Arquitetura de microserviços compatível com EasyPanel
- ✅ Comunicação via DNS interno (service discovery)

**Infraestrutura necessária:**
- PostgreSQL (já disponível com pgvector ✅)
- Redis (criar no EasyPanel)
- 6 aplicações (Auth, Auth-Sidekiq, CRM, CRM-Sidekiq, Core, Processor, Bot Runtime, Frontend)

---

## Fase 0 - Preparação (OBRIGATÓRIA)

### 0.1 Gerar Secrets de Produção

```bash
# Gerar JWT_SECRET_KEY e SECRET_KEY_BASE (mesmo valor)
openssl rand -base64 64 | tr -d '\n'

# Gerar ENCRYPTION_KEY (32 bytes base64 URL-safe)
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Gerar BOT_RUNTIME_SECRET
openssl rand -hex 32

# Gerar EVOAI_CRM_API_TOKEN
uuidgen | tr '[:upper:]' '[:lower:]'

# Gerar DOORKEEPER_JWT_SECRET_KEY (pode ser igual ao SECRET_KEY_BASE)
openssl rand -base64 64 | tr -d '\n'
```

### 0.2 Preparar Repositórios Git

**Opção A: Usar GitHub Container Registry (GHCR)**
```bash
# Build e push das imagens
docker build -t ghcr.io/seu-usuario/evo-auth:latest ./evo-auth-service-community
docker push ghcr.io/seu-usuario/evo-auth:latest

docker build -t ghcr.io/seu-usuario/evo-crm:latest ./evo-ai-crm-community
docker push ghcr.io/seu-usuario/evo-crm:latest

docker build -t ghcr.io/seu-usuario/evo-core:latest ./evo-ai-core-service-community
docker push ghcr.io/seu-usuario/evo-core:latest

docker build -t ghcr.io/seu-usuario/evo-processor:latest ./evo-ai-processor-community
docker push ghcr.io/seu-usuario/evo-processor:latest

docker build -t ghcr.io/seu-usuario/evo-bot-runtime:latest ./evo-bot-runtime
docker push ghcr.io/seu-usuario/evo-bot-runtime:latest

docker build -t ghcr.io/seu-usuario/evo-frontend:latest ./evo-ai-frontend-community
docker push ghcr.io/seu-usuario/evo-frontend:latest
```

**Opção B: Build direto no EasyPanel via GitHub**
- Conectar repositórios GitHub ao EasyPanel
- EasyPanel fará build automático a partir do Dockerfile

---

## Fase 1 - Setup Inicial no EasyPanel

### 1.1 Criar Projeto

1. Acesse EasyPanel
2. Criar novo projeto: `evo-crm-community`
3. Selecionar região/servidor

### 1.2 Provisionar Redis

1. No projeto, adicionar serviço **Redis**
2. Nome: `redis`
3. Versão: `alpine` (latest)
4. Configurar senha: usar a gerada em 0.1
5. Habilitar persistência (volume)
6. Recursos sugeridos:
   - CPU: 0.5 core
   - RAM: 512 MB
   - Storage: 2 GB

### 1.3 Configurar PostgreSQL Existente

**Criar database e extensão:**
```sql
-- Conectar ao PostgreSQL existente
CREATE DATABASE evo_community;

\c evo_community

-- Habilitar extensão pgvector
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

**Anotar credenciais:**
- Host: `<seu-postgres-host>`
- Port: `5432`
- Database: `evo_community`
- User: `<seu-usuario>`
- Password: `<sua-senha>`

---

## Fase 2 - Deploy dos Serviços (ORDEM CRÍTICA)

### 2.1 Deploy: EVO Auth Service (PRIMEIRO)

**Tipo:** App
**Nome:** `evo-auth`
**Porta:** `3001`

**Build:**
- Source: GitHub repo `evo-auth-service-community`
- Dockerfile: `Dockerfile`
- Build context: `/`

**Variáveis de Ambiente:**
```env
RAILS_ENV=production
RAILS_MAX_THREADS=5
RAILS_LOG_TO_STDOUT=true

# Database
POSTGRES_HOST=<seu-postgres-host>
POSTGRES_PORT=5432
POSTGRES_USERNAME=<seu-usuario>
POSTGRES_PASSWORD=<sua-senha>
POSTGRES_DATABASE=evo_community

# Redis
REDIS_URL=redis://:sua-senha-redis@redis:6379/1
REDIS_PASSWORD=sua-senha-redis

# Secrets (usar os gerados em 0.1)
SECRET_KEY_BASE=<gerado-em-0.1>
JWT_SECRET_KEY=<gerado-em-0.1>
DOORKEEPER_JWT_SECRET_KEY=<gerado-em-0.1>
DOORKEEPER_JWT_ALGORITHM=hs256
DOORKEEPER_JWT_ISS=evo-auth-service
DOORKEEPER_JWT_AUD=[]

# URLs (ajustar com seus domínios)
FRONTEND_URL=https://evo.seudominio.com

# Email (configurar SMTP real)
MAILER_SENDER_EMAIL=noreply@seudominio.com
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=seudominio.com
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app

# Storage
ACTIVE_STORAGE_SERVICE=local

# MFA
MFA_ISSUER=EvoAI

# Sidekiq
SIDEKIQ_CONCURRENCY=10

# Outros
ENABLE_ACCOUNT_SIGNUP=true
```

**Comando de Start:**
```bash
bundle install && bundle exec rails db:prepare && bundle exec rails db:seed && bundle exec rails s -p 3001 -b 0.0.0.0
```

**Health Check:**
- Path: `/health`
- Port: `3001`
- Interval: 30s
- Timeout: 10s
- Start period: 90s

**Domínio:**
- Configurar: `auth.seudominio.com`
- Habilitar HTTPS/TLS

**Recursos sugeridos:**
- CPU: 1 core
- RAM: 1 GB
- Storage: 5 GB

---

### 2.2 Deploy: EVO Auth Sidekiq

**Tipo:** App (Worker)
**Nome:** `evo-auth-sidekiq`
**Porta:** Nenhuma (worker)

**Build:** Mesmo do evo-auth

**Variáveis de Ambiente:** Mesmas do evo-auth

**Comando de Start:**
```bash
bundle install && bundle exec sidekiq
```

**Health Check:** Desabilitar (é um worker)

**Recursos sugeridos:**
- CPU: 0.5 core
- RAM: 512 MB

---

### 2.3 Deploy: EVO CRM Service (SEGUNDO)

**Tipo:** App
**Nome:** `evo-crm`
**Porta:** `3000`

**Build:**
- Source: GitHub repo `evo-ai-crm-community`
- Dockerfile: `docker/Dockerfile`
- Build context: `/`

**Variáveis de Ambiente:**
```env
RAILS_ENV=production
RAILS_MAX_THREADS=5
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=false

# Database
POSTGRES_HOST=<seu-postgres-host>
POSTGRES_PORT=5432
POSTGRES_USERNAME=<seu-usuario>
POSTGRES_PASSWORD=<sua-senha>
POSTGRES_DATABASE=evo_community

# Redis
REDIS_URL=redis://:sua-senha-redis@redis:6379/0
REDIS_PASSWORD=sua-senha-redis

# Secrets
SECRET_KEY_BASE=<mesmo-do-auth>
JWT_SECRET_KEY=<mesmo-do-auth>
EVOAI_CRM_API_TOKEN=<gerado-em-0.1>

# URLs internas (DNS do EasyPanel)
EVO_AUTH_SERVICE_URL=http://evo-auth:3001
EVO_AI_CORE_SERVICE_URL=http://evo-core:5555
BOT_RUNTIME_URL=http://evo-bot-runtime:8080

# URLs públicas
BACKEND_URL=https://api.seudominio.com
FRONTEND_URL=https://evo.seudominio.com

# Bot Runtime
BOT_RUNTIME_SECRET=<gerado-em-0.1>
BOT_RUNTIME_POSTBACK_BASE_URL=http://evo-crm:3000

# CORS (ajustar com seus domínios)
CORS_ORIGINS=https://evo.seudominio.com,https://api.seudominio.com

# Features
DISABLE_TELEMETRY=true
ENABLE_ACCOUNT_SIGNUP=true
ENABLE_PUSH_RELAY_SERVER=true
ENABLE_INBOX_EVENTS=true

# Logging
LOG_LEVEL=info
LOG_SIZE=500

# Facebook (se usar)
FB_VERIFY_TOKEN=evolution
FACEBOOK_API_VERSION=v23.0
```

**Comando de Start:**
```bash
bundle exec rails db:prepare && bundle exec rails s -p 3000 -b 0.0.0.0
```

**Health Check:**
- Path: `/health/live`
- Port: `3000`
- Interval: 30s
- Start period: 120s

**Domínio:**
- Configurar: `api.seudominio.com`
- Habilitar HTTPS/TLS

**Recursos sugeridos:**
- CPU: 2 cores
- RAM: 2 GB
- Storage: 10 GB

---

### 2.4 Deploy: EVO CRM Sidekiq

**Tipo:** App (Worker)
**Nome:** `evo-crm-sidekiq`

**Build:** Mesmo do evo-crm

**Variáveis de Ambiente:** Mesmas do evo-crm

**Comando de Start:**
```bash
bundle exec sidekiq -C config/sidekiq.yml
```

**Recursos sugeridos:**
- CPU: 1 core
- RAM: 1 GB

---

### 2.5 Deploy: EVO Core Service (TERCEIRO)

**Tipo:** App
**Nome:** `evo-core`
**Porta:** `5555`

**Build:**
- Source: GitHub repo `evo-ai-core-service-community`
- Dockerfile: `Dockerfile`

**Variáveis de Ambiente:**
```env
# Database
DB_HOST=<seu-postgres-host>
DB_PORT=5432
DB_USER=<seu-usuario>
DB_PASSWORD=<sua-senha>
DB_NAME=evo_community
DB_SSLMODE=disable

# Connection pool
DB_MAX_IDLE_CONNS=10
DB_MAX_OPEN_CONNS=100
DB_CONN_MAX_LIFETIME=1h
DB_CONN_MAX_IDLE_TIME=30m

# Secrets
JWT_SECRET_KEY=<mesmo-do-auth>
JWT_ALGORITHM=HS256
ENCRYPTION_KEY=<gerado-em-0.1>

# URLs internas
EVOLUTION_BASE_URL=http://evo-crm:3000
EVO_AUTH_BASE_URL=http://evo-auth:3001
AI_PROCESSOR_URL=http://evo-processor:8000
AI_PROCESSOR_VERSION=v1

# Server
PORT=5555
```

**Health Check:**
- Path: `/health`
- Port: `5555`
- Interval: 15s
- Start period: 30s

**Domínio:**
- Configurar: `core.seudominio.com`
- Habilitar HTTPS/TLS

**Recursos sugeridos:**
- CPU: 1 core
- RAM: 1 GB
- Storage: 2 GB

---

### 2.6 Deploy: EVO Processor (QUARTO)

**Tipo:** App
**Nome:** `evo-processor`
**Porta:** `8000`

**Build:**
- Source: GitHub repo `evo-ai-processor-community`
- Dockerfile: `Dockerfile`

**Variáveis de Ambiente:**
```env
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
POSTGRES_CONNECTION_STRING=postgresql://<usuario>:<senha>@<host>:5432/evo_community

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=sua-senha-redis
REDIS_DB=0
REDIS_SSL=false
REDIS_KEY_PREFIX=a2a:
REDIS_TTL=3600

# Secrets
JWT_SECRET_KEY=<mesmo-do-auth>
JWT_ALGORITHM=HS256
ENCRYPTION_KEY=<mesmo-do-core>
EVOAI_CRM_API_TOKEN=<mesmo-do-crm>

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

**Health Check:**
- Path: `/health`
- Port: `8000`
- Interval: 30s
- Start period: 30s

**Domínio:**
- Configurar: `processor.seudominio.com`
- Habilitar HTTPS/TLS

**Recursos sugeridos:**
- CPU: 2 cores
- RAM: 2 GB
- Storage: 5 GB

---

### 2.7 Deploy: EVO Bot Runtime (QUINTO)

**Tipo:** App
**Nome:** `evo-bot-runtime`
**Porta:** `8080`

**Build:**
- Source: GitHub repo `evo-bot-runtime`
- Dockerfile: `Dockerfile`

**Variáveis de Ambiente:**
```env
LISTEN_ADDR=0.0.0.0:8080
REDIS_URL=redis://:sua-senha-redis@redis:6379
AI_PROCESSOR_URL=http://evo-processor:8000
BOT_RUNTIME_SECRET=<mesmo-do-crm>
AI_PROCESSOR_API_KEY=<gerado-em-0.1>
AI_CALL_TIMEOUT_SECONDS=30
```

**Health Check:**
- Path: `/health`
- Port: `8080`
- Interval: 15s
- Start period: 15s

**Domínio:**
- Configurar: `bot.seudominio.com` (opcional, pode ser apenas interno)

**Recursos sugeridos:**
- CPU: 1 core
- RAM: 512 MB

---

### 2.8 Deploy: EVO Frontend (ÚLTIMO)

**Tipo:** App
**Nome:** `evo-frontend`
**Porta:** `80`

**Build:**
- Source: GitHub repo `evo-ai-frontend-community`
- Dockerfile: `Dockerfile`
- **Build Args (IMPORTANTE - são build-time):**
  ```
  VITE_API_URL=https://api.seudominio.com
  VITE_AUTH_API_URL=https://auth.seudominio.com
  VITE_EVOAI_API_URL=https://core.seudominio.com
  VITE_AGENT_PROCESSOR_URL=https://processor.seudominio.com
  ```

**Variáveis de Ambiente (runtime):**
```env
VITE_APP_ENV=production
VITE_API_URL=https://api.seudominio.com
VITE_AUTH_API_URL=https://auth.seudominio.com
VITE_WS_URL=https://api.seudominio.com
VITE_EVOAI_API_URL=https://core.seudominio.com
VITE_AGENT_PROCESSOR_URL=https://processor.seudominio.com
VITE_TINYMCE_API_KEY=no-api-key
```

**Health Check:**
- Path: `/health`
- Port: `80`
- Interval: 15s

**Domínio:**
- Configurar: `evo.seudominio.com` ou `app.seudominio.com`
- Habilitar HTTPS/TLS

**Recursos sugeridos:**
- CPU: 0.5 core
- RAM: 256 MB

---

## Fase 3 - Pós-Deploy

### 3.1 Executar Seeds (IMPORTANTE)

**Seed do Auth (primeiro):**
```bash
# No container evo-auth
bundle exec rails db:seed
```

**Seed do CRM (depois):**
```bash
# No container evo-crm
bundle exec rails db:seed
```

### 3.2 Verificar Conectividade

Testar cada endpoint:
```bash
curl https://auth.seudominio.com/health
curl https://api.seudominio.com/health/live
curl https://core.seudominio.com/health
curl https://processor.seudominio.com/health
curl https://bot.seudominio.com/health
curl https://evo.seudominio.com/
```

### 3.3 Teste de Login

1. Acessar `https://evo.seudominio.com`
2. Login com credenciais do seed:
   - Email: `support@evo-auth-service-community.com`
   - Senha: `Password@123`

---

## Fase 4 - Observabilidade e Operação

### 4.1 Logs

EasyPanel já centraliza logs de todos os containers.

**Monitorar:**
- Erros de autenticação
- Falhas de conexão entre serviços
- Erros de migration
- Jobs Sidekiq falhando

### 4.2 Métricas

**Monitorar no EasyPanel:**
- CPU/RAM por serviço
- Restart count
- Response time dos healthchecks

### 4.3 Alertas

Configurar alertas para:
- Container reiniciando em loop (> 3x em 5 min)
- Healthcheck falhando
- Uso de RAM > 90%
- Disco > 85%

---

## Fase 5 - Segurança e Produção

### 5.1 Checklist de Segurança

- [ ] Todos os secrets rotacionados (não usar os de exemplo)
- [ ] HTTPS/TLS habilitado em todos os domínios
- [ ] Firewall configurado (apenas portas necessárias)
- [ ] Backup automático do PostgreSQL configurado
- [ ] Redis com senha forte
- [ ] CORS configurado corretamente
- [ ] Rate limiting habilitado
- [ ] Logs de auditoria ativos

### 5.2 Backup

**PostgreSQL:**
```bash
# Backup diário
pg_dump -h <host> -U <user> -d evo_community > backup_$(date +%Y%m%d).sql

# Restore
psql -h <host> -U <user> -d evo_community < backup_20250420.sql
```

**Redis:**
- EasyPanel já faz snapshot automático se persistência habilitada

### 5.3 Teste de Restore

Testar restore em ambiente de staging antes de ir para produção.

---

## Fase 6 - Go-Live

### 6.1 Checklist Final

- [ ] Todos os serviços healthy
- [ ] Seeds executados
- [ ] Login funcionando
- [ ] Criação de conversa funcionando
- [ ] Agente respondendo
- [ ] Jobs Sidekiq processando
- [ ] WebSocket conectando
- [ ] Notificações funcionando
- [ ] SMTP enviando emails
- [ ] Backup configurado
- [ ] Monitoramento ativo

### 6.2 Smoke Tests

```bash
# 1. Health checks
curl https://auth.seudominio.com/health
curl https://api.seudominio.com/health/live
curl https://core.seudominio.com/health
curl https://processor.seudominio.com/health

# 2. Login via API
curl -X POST https://auth.seudominio.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"support@evo-auth-service-community.com","password":"Password@123"}'

# 3. Verificar token
curl https://auth.seudominio.com/api/v1/auth/me \
  -H "Authorization: Bearer <token>"
```

### 6.3 Plano de Rollback

Se algo der errado:
1. Reverter para imagem anterior no EasyPanel
2. Restaurar backup do banco (se necessário)
3. Verificar logs para identificar problema
4. Corrigir e tentar novamente

---

## 🔧 Troubleshooting e Dicas

### Problema: Serviço não inicia (CrashLoopBackOff)

**Causas comuns:**
1. Variável de ambiente faltando ou incorreta
2. Não consegue conectar ao PostgreSQL/Redis
3. Migration falhando
4. Porta já em uso

**Solução:**
```bash
# Ver logs do container
# No EasyPanel: clicar no serviço > Logs

# Verificar variáveis de ambiente
# No EasyPanel: clicar no serviço > Environment

# Testar conexão com banco
psql -h <host> -U <user> -d evo_community -c "SELECT 1"

# Testar conexão com Redis
redis-cli -h redis -a <senha> ping
```

### Problema: Auth Service não aceita login

**Causas:**
1. Seed não foi executado
2. JWT_SECRET_KEY diferente entre serviços
3. Database não tem usuário

**Solução:**
```bash
# Executar seed novamente
bundle exec rails db:seed

# Verificar se usuário existe
bundle exec rails console
User.find_by(email: 'support@evo-auth-service-community.com')

# Criar usuário manualmente se necessário
User.create!(
  email: 'support@evo-auth-service-community.com',
  password: 'Password@123',
  password_confirmation: 'Password@123',
  confirmed: true
)
```

### Problema: Serviços não se comunicam

**Causas:**
1. DNS interno do EasyPanel não resolvendo
2. URLs internas incorretas
3. Porta errada

**Solução:**
```bash
# Testar DNS interno (dentro de um container)
ping evo-auth
ping redis
ping evo-crm

# Verificar se serviço está escutando
curl http://evo-auth:3001/health
curl http://evo-crm:3000/health/live

# Verificar variáveis de ambiente
echo $EVO_AUTH_SERVICE_URL
echo $REDIS_URL
```

### Problema: Frontend não carrega ou dá erro CORS

**Causas:**
1. Build args do Vite incorretos (URLs hardcoded no build)
2. CORS não configurado no backend
3. HTTPS/HTTP mismatch

**Solução:**
```bash
# Rebuild do frontend com URLs corretas
# No EasyPanel: Rebuild com build args corretos

# Verificar CORS no CRM
# Adicionar domínio do frontend em CORS_ORIGINS
CORS_ORIGINS=https://evo.seudominio.com,https://api.seudominio.com

# Verificar se todos os serviços estão em HTTPS
# Não misturar HTTP e HTTPS
```

### Problema: Sidekiq não processa jobs

**Causas:**
1. Redis não conectado
2. Sidekiq não iniciado
3. Fila errada

**Solução:**
```bash
# Verificar se Sidekiq está rodando
ps aux | grep sidekiq

# Verificar conexão Redis
bundle exec rails console
Sidekiq.redis { |conn| conn.ping }

# Ver filas
bundle exec rails console
Sidekiq::Queue.all.map(&:name)

# Limpar fila (se necessário)
Sidekiq::Queue.new('default').clear
```

### Problema: Migrations falhando

**Causas:**
1. Extensão pgvector não instalada
2. Permissões insuficientes
3. Migration já executada parcialmente

**Solução:**
```bash
# Verificar extensões
psql -h <host> -U <user> -d evo_community -c "\dx"

# Instalar pgvector se necessário
psql -h <host> -U <user> -d evo_community -c "CREATE EXTENSION IF NOT EXISTS vector;"

# Ver status das migrations
bundle exec rails db:migrate:status

# Rollback se necessário
bundle exec rails db:rollback STEP=1

# Executar novamente
bundle exec rails db:migrate
```

### Problema: Alto uso de memória

**Causas:**
1. Sidekiq com muitas threads
2. Connection pool muito grande
3. Memory leak

**Solução:**
```bash
# Reduzir threads do Sidekiq
SIDEKIQ_CONCURRENCY=5

# Reduzir connection pool
RAILS_MAX_THREADS=3
DB_MAX_OPEN_CONNS=50

# Reiniciar serviço periodicamente (workaround)
# No EasyPanel: configurar restart policy
```

### Problema: WebSocket não conecta

**Causas:**
1. Proxy reverso não suporta WebSocket
2. CORS bloqueando
3. URL incorreta

**Solução:**
```bash
# Verificar se ActionCable está configurado
# No CRM: config/cable.yml

# Testar WebSocket manualmente
wscat -c wss://api.seudominio.com/cable

# Verificar headers CORS
curl -I https://api.seudominio.com/cable \
  -H "Origin: https://evo.seudominio.com" \
  -H "Upgrade: websocket"
```

---

## 📊 Matriz de Variáveis de Ambiente

### Variáveis Compartilhadas (DEVEM SER IGUAIS)

| Variável | Usado por | Descrição |
|----------|-----------|-----------|
| `SECRET_KEY_BASE` | Auth, CRM | JWT signing key |
| `JWT_SECRET_KEY` | Auth, CRM, Core, Processor | JWT validation |
| `ENCRYPTION_KEY` | Core, Processor | API key encryption |
| `EVOAI_CRM_API_TOKEN` | CRM, Processor | Service-to-service auth |
| `BOT_RUNTIME_SECRET` | CRM, Bot Runtime | Bot authentication |

### Variáveis de Conexão

| Variável | Formato | Exemplo |
|----------|---------|---------|
| `POSTGRES_HOST` | hostname | `postgres.easypanel.host` |
| `POSTGRES_CONNECTION_STRING` | URI | `postgresql://user:pass@host:5432/db` |
| `REDIS_URL` | URI | `redis://:senha@redis:6379/0` |

### URLs Internas (DNS do EasyPanel)

| Variável | Valor | Usado por |
|----------|-------|-----------|
| `EVO_AUTH_SERVICE_URL` | `http://evo-auth:3001` | CRM, Core, Processor |
| `EVO_AI_CORE_SERVICE_URL` | `http://evo-core:5555` | CRM, Processor |
| `EVOLUTION_BASE_URL` | `http://evo-crm:3000` | Core, Processor |
| `AI_PROCESSOR_URL` | `http://evo-processor:8000` | Core, Bot Runtime |
| `BOT_RUNTIME_URL` | `http://evo-bot-runtime:8080` | CRM |

### URLs Públicas (Domínios)

| Variável | Valor | Usado por |
|----------|-------|-----------|
| `FRONTEND_URL` | `https://evo.seudominio.com` | Auth, CRM |
| `BACKEND_URL` | `https://api.seudominio.com` | CRM |
| `VITE_API_URL` | `https://api.seudominio.com` | Frontend (build) |
| `VITE_AUTH_API_URL` | `https://auth.seudominio.com` | Frontend (build) |

---

## 🎯 Checklist de Deploy

### Pré-Deploy
- [ ] PostgreSQL com pgvector instalado e testado
- [ ] Redis provisionado no EasyPanel
- [ ] Todos os secrets gerados e salvos em local seguro
- [ ] Domínios configurados e apontando para EasyPanel
- [ ] SMTP configurado para envio de emails
- [ ] Repositórios Git conectados ao EasyPanel (ou imagens no registry)

### Deploy
- [ ] Redis healthy
- [ ] Auth Service deployed e healthy
- [ ] Auth Sidekiq deployed e rodando
- [ ] Auth seed executado com sucesso
- [ ] CRM Service deployed e healthy
- [ ] CRM Sidekiq deployed e rodando
- [ ] CRM seed executado com sucesso
- [ ] Core Service deployed e healthy
- [ ] Processor Service deployed e healthy
- [ ] Bot Runtime deployed e healthy
- [ ] Frontend deployed e acessível

### Pós-Deploy
- [ ] Todos os healthchecks passando
- [ ] Login funcionando no frontend
- [ ] Criação de conversa funcionando
- [ ] Agente respondendo mensagens
- [ ] Jobs Sidekiq processando
- [ ] WebSocket conectando
- [ ] Notificações em tempo real funcionando
- [ ] Emails sendo enviados
- [ ] Logs sem erros críticos

### Segurança
- [ ] Todos os secrets rotacionados (não usar defaults)
- [ ] HTTPS habilitado em todos os domínios
- [ ] CORS configurado corretamente
- [ ] Rate limiting ativo
- [ ] Backup automático configurado
- [ ] Monitoramento e alertas ativos

---

## 📚 Recursos Adicionais

### Documentação Oficial
- [EasyPanel Docs](https://easypanel.io/docs)
- [PostgreSQL pgvector](https://github.com/pgvector/pgvector)
- [Rails Deployment](https://guides.rubyonrails.org/deployment.html)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

### Comandos Úteis

**Gerar secrets:**
```bash
# JWT Secret (64 bytes base64)
openssl rand -base64 64 | tr -d '\n'

# Encryption Key (32 bytes URL-safe base64)
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# UUID
uuidgen | tr '[:upper:]' '[:lower:]'

# Random hex (32 bytes)
openssl rand -hex 32
```

**Database:**
```bash
# Backup
pg_dump -h host -U user -d evo_community -F c -f backup.dump

# Restore
pg_restore -h host -U user -d evo_community backup.dump

# Verificar tamanho
psql -h host -U user -d evo_community -c "SELECT pg_size_pretty(pg_database_size('evo_community'));"
```

**Redis:**
```bash
# Info
redis-cli -h redis -a senha INFO

# Limpar cache
redis-cli -h redis -a senha FLUSHDB

# Ver keys
redis-cli -h redis -a senha KEYS "*"
```

---

## 🚀 Próximos Passos Recomendados

1. **Ambiente de Staging:** Criar ambiente de teste antes de produção
2. **CI/CD:** Configurar pipeline automático de deploy
3. **Monitoring:** Integrar com Sentry, Datadog ou New Relic
4. **Backup:** Testar restore de backup regularmente
5. **Scaling:** Configurar auto-scaling baseado em métricas
6. **CDN:** Adicionar CDN para assets estáticos do frontend
7. **Cache:** Implementar cache HTTP com Cloudflare ou similar
8. **Documentação:** Documentar processos operacionais da equipe

---

**Última atualização:** 2025-04-20  
**Versão:** 2.0 - Deploy EasyPanel Completo

---

## 7) Riscos conhecidos e mitigacao

- **Risco:** divergencia entre estado de migration e esquema do banco.  
  **Mitigacao:** migration runner unico por ambiente + backup antes de migrar.

- **Risco:** falhas por CRLF em scripts shell em pipeline Windows.  
  **Mitigacao:** enforcement de LF com `.gitattributes`.

- **Risco:** healthcheck apontando para endpoint incorreto.  
  **Mitigacao:** teste automatizado de health endpoints em CI.

- **Risco:** secrets de desenvolvimento em producao.  
  **Mitigacao:** vault/secret manager + rotacao periodica.

---

## 8) Proximos passos recomendados

1. Criar `.gitattributes` para forcar `*.sh` com LF.
2. Definir pipeline CI/CD para build e publicacao de imagens.
3. Criar compose/stack de `staging` especifico para EasyPanel.
4. Documentar matriz final de variaveis de ambiente por servico.
5. Executar primeiro deploy em staging com teste de ponta a ponta.
