# ⚡ CORREÇÕES FINAIS - Variáveis de Ambiente

## 🎯 RESUMO

Analisei todas as configurações e encontrei **4 problemas** que precisam ser corrigidos.

---

## 🔴 CORREÇÕES NECESSÁRIAS

### 1️⃣ evo-auth - Redis URL

**No Easypanel → evo-auth → Ambiente:**

**Mudar de:**
```env
REDIS_URL=redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/1
```

**Para:**
```env
REDIS_URL=redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379/1
```

**Salvar e Reiniciar**

---

### 2️⃣ evo-core - Database Name

**No Easypanel → evo-core → Ambiente:**

**Mudar de:**
```env
DB_NAME=postgres
```

**Para:**
```env
DB_NAME=evo_community
```

**Salvar e Reiniciar**

---

### 3️⃣ evo-processor - Connection String

**No Easypanel → evo-processor → Ambiente:**

**Mudar de:**
```env
POSTGRES_CONNECTION_STRING=postgresql://postgres:355cbf3375d96724de1f@evogo_postgres:5432/postgres
```

**Para:**
```env
POSTGRES_CONNECTION_STRING=postgresql://postgres:355cbf3375d96724de1f@evogo_postgres:5432/evo_community
```

**Salvar e Reiniciar**

---

### 4️⃣ evo-frontend - Build Args

**No Easypanel → evo-frontend → Fonte (Source) → Build Arguments:**

**Adicionar:**
```
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
```

**Salvar e Rebuild**

---

## 📋 CHECKLIST DE EXECUÇÃO

Execute nesta ordem:

- [ ] 1. evo-auth → Corrigir REDIS_URL → Reiniciar
- [ ] 2. evo-core → Corrigir DB_NAME → Reiniciar
- [ ] 3. evo-processor → Corrigir POSTGRES_CONNECTION_STRING → Reiniciar
- [ ] 4. evo-frontend → Adicionar Build Args → Rebuild
- [ ] 5. Aguardar todos os serviços ficarem Running
- [ ] 6. Testar health checks
- [ ] 7. Testar login no frontend

---

## ⏱️ TEMPO TOTAL: 10 MINUTOS

- Correção 1: 1 min
- Correção 2: 1 min
- Correção 3: 1 min
- Correção 4: 2 min
- Rebuild frontend: 3 min
- Verificação: 2 min

---

## ✅ RESULTADO ESPERADO

Após as correções:

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

## 🧪 TESTES

### 1. Health Checks

```bash
curl https://auth.macip.com.br/health
curl https://api.macip.com.br/health/live
curl https://core.macip.com.br/health
curl https://processor.macip.com.br/health
```

Todos devem retornar status OK.

### 2. Frontend

```
1. Abrir: https://evo.macip.com.br
2. Deve carregar a página de login
3. Abrir Console (F12) → Não deve ter erros
```

### 3. Login

```
URL: https://evo.macip.com.br
Email: support@evo-auth-service-community.com
Senha: Password@123
```

Deve entrar no dashboard.

---

## 📝 VALORES CORRETOS (REFERÊNCIA)

### Database
```
Host: evogo_postgres
Port: 5432
Username: postgres
Password: 355cbf3375d96724de1f
Database: evo_community
```

### Redis
```
URL: redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379
Auth (DB 1): redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379/1
CRM (DB 0): redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379/0
```

---

## 🎉 APÓS CONCLUSÃO

Sistema completamente operacional:
- ✅ Todas as variáveis corretas
- ✅ Todos os serviços Running
- ✅ Frontend funcionando
- ✅ Backend funcionando
- ✅ Autenticação funcionando
- ✅ Pronto para uso em produção

---

**👉 Comece pela correção 1 (evo-auth) e siga a ordem!**

---

**Última atualização:** 21/04/2026  
**Status:** 4 correções identificadas  
**Tempo:** 10 minutos para resolver tudo
