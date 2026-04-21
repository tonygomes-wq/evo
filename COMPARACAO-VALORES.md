# 🔍 Comparação: Valores Errados vs Corretos

## Guia Visual de Correção

---

## 🔴 POSTGRES_PASSWORD

### ❌ VALOR ERRADO (Atual)
```
355cbf3375d96724d0ff
                    ^^^^
                    ERRADO
```

### ✅ VALOR CORRETO
```
355cbf3375d96724de1f
                    ^^^^
                    CORRETO
```

### 📝 Diferença
```
Posição: Últimos 4 caracteres
Errado:  d0ff
Correto: de1f

Mudar apenas: 0 → e  e  f → 1
```

---

## 🔴 REDIS_URL

### ❌ POSSÍVEIS VALORES ERRADOS

**Erro 1: Sem senha**
```
redis://evogo_redis:6379/0
      ^^
      Falta :senha@
```

**Erro 2: Sem dois pontos antes da senha**
```
redis://dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0
      ^^
      Falta : antes da senha
```

**Erro 3: Sem arroba depois da senha**
```
redis://:dpkjzl4kz7riuI5ah7rfevogo_redis:6379/0
                              ^^
                              Falta @
```

### ✅ VALOR CORRETO
```
redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0
       ↑                      ↑
       Dois pontos            Arroba
       antes da senha         depois da senha
```

### 📝 Estrutura Correta
```
redis://  :  senha  @  host  :  porta  /  db
         ↑         ↑        ↑        ↑
         |         |        |        |
         |         |        |        Número do banco (0)
         |         |        Porta (6379)
         |         Host (evogo_redis)
         Senha (dpkjzl4kz7riuI5ah7rf)
```

---

## 🔴 BUILD PATH (evo-crm-sidekiq)

### ❌ VALOR ERRADO (Atual)
```
/evo-ai-crm-community-main
↑
Barra inicial INCORRETA
```

### ✅ VALOR CORRETO
```
evo-ai-crm-community-main
↑
SEM barra inicial
```

### 📝 Explicação
```
Com barra:    /evo-ai-crm-community-main
              ↑ Caminho absoluto (errado no Easypanel)

Sem barra:    evo-ai-crm-community-main
              ↑ Caminho relativo (correto no Easypanel)
```

---

## 📊 Tabela Comparativa Completa

| Variável | Valor Errado | Valor Correto | Onde Corrigir |
|----------|--------------|---------------|---------------|
| POSTGRES_PASSWORD | `355cbf3375d96724d0ff` | `355cbf3375d96724de1f` | evo-crm, evo-crm-sidekiq |
| REDIS_URL | Vários possíveis | `redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0` | evo-crm, evo-crm-sidekiq |
| Build Path | `/evo-ai-crm-community-main` | `evo-ai-crm-community-main` | evo-crm-sidekiq |

---

## 🎯 Como Identificar o Erro nos Logs

### Erro de Senha PostgreSQL
```
❌ Logs mostram:
PG::ConnectionBad: FATAL: password authentication failed for user "postgres"

✅ Solução:
Corrigir POSTGRES_PASSWORD para: 355cbf3375d96724de1f
```

### Erro de Senha Redis
```
❌ Logs mostram:
WRONGPASS invalid username-password pair
ou
NOAUTH Authentication required

✅ Solução:
Corrigir REDIS_URL para: redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0
```

### Erro de Build Path
```
❌ Logs mostram:
/evo-crm-community-main/evo-ai-crm-community/docker: no such file or directory

✅ Solução:
Remover barra inicial do Build Path
```

### Erro de Migração
```
❌ Logs mostram:
PG::DuplicateColumn: column "sentiment_offensive" already exists

✅ Solução:
Executar no console:
bundle exec rails runner "ActiveRecord::Base.connection.execute(\"INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING\")"
```

---

## 📋 Checklist de Verificação Visual

### evo-crm - Variáveis de Ambiente

```
✅ POSTGRES_HOST=evogo_postgres
✅ POSTGRES_PORT=5432
✅ POSTGRES_USERNAME=postgres
🔍 POSTGRES_PASSWORD=355cbf3375d96724de1f
   └─ Verificar: termina com "de1f" (não "d0ff")

✅ POSTGRES_DATABASE=evo_community

🔍 REDIS_URL=redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0
   ├─ Verificar: tem ":" antes da senha
   ├─ Verificar: tem "@" depois da senha
   └─ Verificar: termina com "/0"

✅ SECRET_KEY_BASE=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
✅ JWT_SECRET_KEY=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
✅ EVOAI_CRM_API_TOKEN=22d16004-2706-4df5-a9e4-31dc35053816
✅ BOT_RUNTIME_SECRET=6c042ef5122814fe0ca8224908957ba39a55dfd1f0c3ae1dd8c4e0a3f5623b50
✅ ENCRYPTION_KEY=G5ceki9s9/Klo5rR0IKJONPx6mxHVeLASqR518klR7Q=
```

### evo-crm-sidekiq - Configuração de Build

```
🔍 Caminho de Build: evo-ai-crm-community-main
   └─ Verificar: NÃO começa com "/"

✅ Dockerfile: docker/Dockerfile
```

---

## 🔧 Comandos de Verificação

### Verificar se senha PostgreSQL está correta
```bash
# No terminal do servidor
PGPASSWORD=355cbf3375d96724de1f psql -h evogo_postgres -U postgres -d evo_community -c "SELECT 1"

# Deve retornar:
 ?column? 
----------
        1
```

### Verificar se Redis está acessível
```bash
# No console do evo-crm
bundle exec rails runner "puts Redis.new(url: 'redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0').ping"

# Deve retornar:
PONG
```

### Verificar se migração foi executada
```bash
# No console do evo-crm
bundle exec rails runner "puts ActiveRecord::Base.connection.execute('SELECT version FROM schema_migrations WHERE version = \\'20251114150000\\'').to_a"

# Se retornar vazio, executar:
bundle exec rails runner "ActiveRecord::Base.connection.execute(\"INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING\")"
```

---

## 📝 Template de Variáveis Corretas

### Para copiar e colar no Easypanel

#### evo-crm e evo-crm-sidekiq - Ambiente
```env
RAILS_ENV=production
RAILS_MAX_THREADS=5
RAILS_LOG_TO_STDOUT=true

POSTGRES_HOST=evogo_postgres
POSTGRES_PORT=5432
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=355cbf3375d96724de1f
POSTGRES_DATABASE=evo_community

REDIS_URL=redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0

SECRET_KEY_BASE=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
JWT_SECRET_KEY=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
EVOAI_CRM_API_TOKEN=22d16004-2706-4df5-a9e4-31dc35053816
BOT_RUNTIME_SECRET=6c042ef5122814fe0ca8224908957ba39a55dfd1f0c3ae1dd8c4e0a3f5623b50
ENCRYPTION_KEY=G5ceki9s9/Klo5rR0IKJONPx6mxHVeLASqR518klR7Q=

EVO_AUTH_SERVICE_URL=http://evo-auth:3001
EVO_AI_CORE_SERVICE_URL=http://evo-core:5555
BOT_RUNTIME_URL=http://evo-bot-runtime:8080
BOT_RUNTIME_POSTBACK_BASE_URL=http://evo-crm:3000

BACKEND_URL=https://api.macip.com.br
FRONTEND_URL=https://evo.macip.com.br
CORS_ORIGINS=https://evo.macip.com.br,https://api.macip.com.br

DISABLE_TELEMETRY=true
ENABLE_ACCOUNT_SIGNUP=true
ENABLE_PUSH_RELAY_SERVER=true
ENABLE_INBOX_EVENTS=true
LOG_LEVEL=info
LOG_SIZE=500
FB_VERIFY_TOKEN=evolution
FACEBOOK_API_VERSION=v23.0
```

---

## 🎯 Pontos Críticos de Atenção

### 1. POSTGRES_PASSWORD
```
❌ NÃO usar: 355cbf3375d96724d0ff
✅ USAR:     355cbf3375d96724de1f

Diferença: apenas os últimos 4 caracteres
```

### 2. REDIS_URL
```
❌ NÃO usar: redis://evogo_redis:6379/0
❌ NÃO usar: redis://dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0
✅ USAR:     redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0

Atenção: Precisa ter ":" antes da senha
```

### 3. Build Path
```
❌ NÃO usar: /evo-ai-crm-community-main
✅ USAR:     evo-ai-crm-community-main

Atenção: SEM barra inicial
```

---

## 📞 Resumo das Correções

| # | Serviço | Campo | Ação | Tempo |
|---|---------|-------|------|-------|
| 1 | evo-crm | POSTGRES_PASSWORD | Corrigir últimos 4 chars | 30s |
| 2 | evo-crm | REDIS_URL | Adicionar : antes da senha | 30s |
| 3 | evo-crm | - | Salvar e Reiniciar | 1min |
| 4 | evo-crm | Console | Fix migração (se necessário) | 1min |
| 5 | evo-crm-sidekiq | Build Path | Remover barra inicial | 30s |
| 6 | evo-crm-sidekiq | POSTGRES_PASSWORD | Corrigir últimos 4 chars | 30s |
| 7 | evo-crm-sidekiq | REDIS_URL | Adicionar : antes da senha | 30s |
| 8 | evo-crm-sidekiq | - | Salvar e Rebuild | 3min |

**Total: ~8 minutos**

---

**Última atualização:** 21/04/2026
**Uso:** Guia visual para correção de valores incorretos
