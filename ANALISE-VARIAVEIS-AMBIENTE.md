# 🔍 Análise das Variáveis de Ambiente

## ✅ RESUMO GERAL

A maioria das configurações está correta! Encontrei apenas **alguns problemas** que precisam ser corrigidos.

---

## 🔴 PROBLEMAS IDENTIFICADOS

### 1. evo-auth - Redis URL Incorreta

**❌ Atual:**
```env
REDIS_URL=redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/1
```

**✅ Correto:**
```env
REDIS_URL=redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379/1
```

**Problema:** Senha do Redis está incorreta

---

### 2. evo-core - Database Incorreto

**❌ Atual:**
```env
DB_NAME=postgres
```

**✅ Correto:**
```env
DB_NAME=evo_community
```

**Problema:** Deve usar o banco `evo_community`, não `postgres`

---

### 3. evo-processor - Database Incorreto

**❌ Atual:**
```env
POSTGRES_CONNECTION_STRING=postgresql://postgres:355cbf3375d96724de1f@evogo_postgres:5432/postgres
```

**✅ Correto:**
```env
POSTGRES_CONNECTION_STRING=postgresql://postgres:355cbf3375d96724de1f@evogo_postgres:5432/evo_community
```

**Problema:** Deve usar o banco `evo_community`, não `postgres`

---

### 4. evo-frontend - Faltam Build Args

**Problema:** As variáveis VITE_* precisam ser configuradas como **Build Arguments** também!

**No Easypanel → evo-frontend → Fonte → Build Arguments:**

Adicionar:
```
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
```

---

## ✅ CONFIGURAÇÕES CORRETAS

### evo-crm ✅
- ✅ Database correto (evo_community)
- ✅ Redis URL correto
- ✅ JWT_SECRET_KEY correto
- ✅ CORS_ORIGINS correto
- ✅ URLs internas corretas
- ✅ URLs públicas corretas

### evo-crm-sidekiq ✅
- Usa as mesmas variáveis do evo-crm

### evo-bot-runtime ✅
- ✅ Redis URL correto
- ✅ AI_PROCESSOR_URL correto
- ✅ BOT_RUNTIME_SECRET correto

---

## 📝 CORREÇÕES NECESSÁRIAS

### 1. Corrigir evo-auth

**No Easypanel → evo-auth → Ambiente:**

Localizar:
```env
REDIS_URL=redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/1
```

Mudar para:
```env
REDIS_URL=redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379/1
```

**Salvar e Reiniciar**

---

### 2. Corrigir evo-core

**No Easypanel → evo-core → Ambiente:**

Localizar:
```env
DB_NAME=postgres
```

Mudar para:
```env
DB_NAME=evo_community
```

**Salvar e Reiniciar**

---

### 3. Corrigir evo-processor

**No Easypanel → evo-processor → Ambiente:**

Localizar:
```env
POSTGRES_CONNECTION_STRING=postgresql://postgres:355cbf3375d96724de1f@evogo_postgres:5432/postgres
```

Mudar para:
```env
POSTGRES_CONNECTION_STRING=postgresql://postgres:355cbf3375d96724de1f@evogo_postgres:5432/evo_community
```

**Salvar e Reiniciar**

---

### 4. Configurar Build Args do evo-frontend

**No Easypanel → evo-frontend → Fonte (Source):**

Na seção **"Build Arguments"** ou **"Args de Build"**, adicionar:

```
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
```

**Salvar e Rebuild**

---

## 📋 CHECKLIST DE CORREÇÕES

### evo-auth
- [ ] REDIS_URL corrigido para `redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379/1`
- [ ] Serviço reiniciado
- [ ] Logs verificados (sem erros)

### evo-core
- [ ] DB_NAME corrigido para `evo_community`
- [ ] Serviço reiniciado
- [ ] Logs verificados (sem erros)

### evo-processor
- [ ] POSTGRES_CONNECTION_STRING corrigido para usar `evo_community`
- [ ] Serviço reiniciado
- [ ] Logs verificados (sem erros)

### evo-frontend
- [ ] Build Args adicionados
- [ ] Rebuild executado
- [ ] Frontend carregando
- [ ] Console do navegador sem erros

---

## 🎯 ORDEM DE EXECUÇÃO

Execute nesta ordem:

1. **evo-auth** → Corrigir Redis URL → Reiniciar
2. **evo-core** → Corrigir DB_NAME → Reiniciar
3. **evo-processor** → Corrigir POSTGRES_CONNECTION_STRING → Reiniciar
4. **evo-frontend** → Adicionar Build Args → Rebuild

---

## ⏱️ TEMPO ESTIMADO

- Corrigir evo-auth: 1 min
- Corrigir evo-core: 1 min
- Corrigir evo-processor: 1 min
- Configurar frontend: 2 min
- Rebuild frontend: 3 min
- Verificar: 2 min
- **Total: 10 minutos**

---

## ✅ APÓS CORREÇÕES

Todos os serviços devem estar funcionando:

```
✅ evo-auth: Running (Redis correto)
✅ evo-auth-sidekiq: Running
✅ evo-bot-runtime: Running
✅ evo-core: Running (Database correto)
✅ evo-frontend: Running (Build Args configurados)
✅ evo-processor: Running (Database correto)
✅ evo-crm: Running
✅ evo-crm-sidekiq: Running
```

---

## 🧪 TESTES FINAIS

### 1. Health Checks

```bash
curl https://auth.macip.com.br/health
curl https://api.macip.com.br/health/live
curl https://core.macip.com.br/health
curl https://processor.macip.com.br/health
```

### 2. Frontend

```
1. Abrir: https://evo.macip.com.br
2. Verificar se carrega
3. Abrir Console (F12)
4. Verificar se não há erros
5. Tentar fazer login
```

### 3. Login Completo

```
URL: https://evo.macip.com.br
Email: support@evo-auth-service-community.com
Senha: Password@123
```

---

## 📊 RESUMO DAS VARIÁVEIS CORRETAS

### Senhas e Tokens (Todos os Serviços)
```
PostgreSQL Password: 355cbf3375d96724de1f
Redis Password: d9kizl4kz7riul5ah7if
JWT_SECRET_KEY: +ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
ENCRYPTION_KEY: G5ceki9s9/Klo5rR0IKJONPx6mxHVeLASqR518klR7Q=
EVOAI_CRM_API_TOKEN: 22d16004-2706-4df5-a9e4-31dc35053816
BOT_RUNTIME_SECRET: 6c042ef5122814fe0ca8224908957ba39a55dfd1f0c3ae1dd8c4e0a3f5623b50
```

### Database
```
Host: evogo_postgres
Port: 5432
Username: postgres
Password: 355cbf3375d96724de1f
Database: evo_community ← IMPORTANTE!
```

### Redis
```
URL: redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379
Auth: redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379/1
CRM: redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379/0
```

### URLs Públicas
```
Frontend: https://evo.macip.com.br
Backend: https://api.macip.com.br
Auth: https://auth.macip.com.br
Core: https://core.macip.com.br
Processor: https://processor.macip.com.br
```

---

**Última atualização:** 21/04/2026  
**Status:** 4 correções necessárias  
**Prioridade:** ALTA
