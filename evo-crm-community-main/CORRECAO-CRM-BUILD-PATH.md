# ✅ Correção: Build Path do CRM Service

**Data:** 2025-04-20  
**Status:** ✅ Problema Resolvido

---

## 🎯 Problema

O build do CRM falhou porque o **Build Path** estava apontando para uma pasta com submodule vazio:
- ❌ Build Path antigo: `/evo-crm-community-main/evo-ai-crm-community` (submodule vazio)

---

## ✅ Solução

Foi adicionada uma nova pasta **standalone** na raiz do repositório GitHub:
- ✅ Build Path correto: `/evo-ai-crm-community-main` (pasta completa)

---

## 🔧 Como Corrigir no EasyPanel

### Passo 1: Atualizar Build Path

No EasyPanel, para o serviço **evo-crm**:

1. Ir em **Settings** → **Source** (ou Build)
2. Alterar **Build Path** de:
   ```
   /evo-crm-community-main/evo-ai-crm-community
   ```
   Para:
   ```
   /evo-ai-crm-community-main
   ```

3. Alterar **Build Context** de:
   ```
   /evo-crm-community-main/evo-ai-crm-community
   ```
   Para:
   ```
   /evo-ai-crm-community-main
   ```

4. **Dockerfile Path** permanece o mesmo:
   ```
   docker/Dockerfile
   ```

### Passo 2: Rebuild

1. Ir em **Actions** → **Rebuild**
2. Aguardar o build completar
3. Verificar logs para confirmar sucesso

---

## 📋 Configuração Completa Correta

### CRM Service (evo-crm)

```yaml
Repository: tonygomes-wq/evo
Branch: main
Build Path: /evo-ai-crm-community-main
Dockerfile Path: docker/Dockerfile
Build Context: /evo-ai-crm-community-main
Port: 3000
Domain: api.macip.com.br
```

**Environment Variables:**
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
BACKEND_URL=https://api.macip.com.br
FRONTEND_URL=https://evo.macip.com.br
CORS_ORIGINS=https://evo.macip.com.br,https://api.macip.com.br

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

### CRM Sidekiq (evo-crm-sidekiq)

```yaml
Repository: tonygomes-wq/evo
Branch: main
Build Path: /evo-ai-crm-community-main
Dockerfile Path: docker/Dockerfile
Build Context: /evo-ai-crm-community-main
Port: (deixar vazio - é um worker)
```

**Environment Variables:** Mesmas do CRM Service

**Command:**
```bash
bundle exec sidekiq -C config/sidekiq.yml
```

---

## 📊 Tabela Atualizada de Build Paths

| Serviço | Build Path | Dockerfile Path |
|---------|------------|-----------------|
| evo-auth | `/evo-auth-service-community-main` | `Dockerfile` |
| evo-auth-sidekiq | `/evo-auth-service-community-main` | `Dockerfile` |
| **evo-crm** | **`/evo-ai-crm-community-main`** ✅ | `docker/Dockerfile` |
| **evo-crm-sidekiq** | **`/evo-ai-crm-community-main`** ✅ | `docker/Dockerfile` |
| evo-core | `/evo-ai-core-service-community-main` | `Dockerfile` |
| evo-processor | `/evo-ai-processor-community-main` | `Dockerfile` |
| evo-bot-runtime | `/evo-bot-runtime-main` | `Dockerfile` |
| evo-frontend | `/evo-ai-frontend-community-main` | `Dockerfile` |

---

## ✅ Verificação

Após o rebuild, verificar:

1. **Build completa com sucesso**
   ```
   ✅ Dockerfile encontrado
   ✅ Dependências instaladas
   ✅ Assets compilados
   ✅ Imagem criada
   ```

2. **Container inicia**
   ```
   ✅ Rails server iniciado
   ✅ Conectado ao PostgreSQL
   ✅ Conectado ao Redis
   ```

3. **Health check passa**
   ```bash
   curl https://api.macip.com.br/health/live
   # Deve retornar 200 OK
   ```

---

## 🎯 Próximos Passos

Após corrigir o CRM:

1. ✅ Fazer rebuild do **evo-crm**
2. ✅ Fazer rebuild do **evo-crm-sidekiq**
3. ✅ Executar seed do CRM:
   ```bash
   bundle exec rails db:seed
   ```
4. ✅ Testar health check
5. ✅ Continuar com próximos serviços (Core, Processor, Bot, Frontend)

---

## 📞 Troubleshooting

### Se o build ainda falhar:

1. **Verificar logs do build**
   - Procurar por "Dockerfile not found"
   - Verificar se o path está correto

2. **Verificar no GitHub**
   - Acessar: https://github.com/tonygomes-wq/evo
   - Confirmar que pasta `evo-ai-crm-community-main` existe na raiz
   - Confirmar que tem arquivo `docker/Dockerfile`

3. **Limpar cache do EasyPanel**
   - Algumas vezes o cache pode causar problemas
   - Tentar fazer "Clean Build" se disponível

---

**Status:** ✅ Build Path corrigido  
**Próximo passo:** Fazer rebuild no EasyPanel

