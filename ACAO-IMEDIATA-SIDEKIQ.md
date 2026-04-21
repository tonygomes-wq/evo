# ⚡ AÇÃO IMEDIATA - Corrigir evo-crm-sidekiq

## 🎯 PROBLEMA RESOLVIDO

O Dockerfile foi atualizado para criar um arquivo `.env` vazio, resolvendo o erro:
```
ENOENT: no such file or directory, open '.../.env'
```

---

## ✅ PASSO 1: Rebuild do evo-crm-sidekiq (2 minutos)

### No Easypanel:

1. **Acessar:**
   - Projeto: `evogo`
   - Serviço: `evo-crm-sidekiq`

2. **Verificar Configuração de Build:**
   - Aba: **"Fonte"** (Source)
   - Caminho de Build: `evo-ai-crm-community-main` (SEM barra inicial `/`)
   - Dockerfile: `docker/Dockerfile`

3. **Verificar Comando:**
   - Aba: **"Geral"** (General)
   - Campo "Comando" ou "Start Command": `bundle exec sidekiq -C config/sidekiq.yml`

4. **Rebuild:**
   - Clicar em **"Rebuild"**
   - Aguardar 2-3 minutos

---

## ✅ PASSO 2: Rebuild do evo-crm (1 minuto)

O mesmo Dockerfile é usado pelo evo-crm, então também precisa rebuild:

### No Easypanel:

1. **Acessar:**
   - Projeto: `evogo`
   - Serviço: `evo-crm`

2. **Rebuild:**
   - Clicar em **"Rebuild"**
   - Aguardar 2-3 minutos

---

## ✅ PASSO 3: Verificar (1 minuto)

### Verificar Logs do evo-crm-sidekiq

Deve mostrar:
```
✅ Booting Sidekiq
✅ Running in ruby
✅ Starting processing
```

### Verificar Logs do evo-crm

Deve mostrar:
```
✅ Puma starting in cluster mode
✅ Listening on http://0.0.0.0:3000
```

### Testar Health Check

```bash
curl https://api.macip.com.br/health/live
```

Deve retornar:
```json
{"status":"ok"}
```

---

## 📋 CHECKLIST RÁPIDO

### evo-crm-sidekiq
- [ ] Caminho de Build: `evo-ai-crm-community-main` (sem /)
- [ ] Dockerfile: `docker/Dockerfile`
- [ ] Comando: `bundle exec sidekiq -C config/sidekiq.yml`
- [ ] Rebuild executado
- [ ] Build completado com sucesso
- [ ] Serviço Running
- [ ] Logs mostram "Booting Sidekiq"

### evo-crm
- [ ] Rebuild executado
- [ ] Build completado com sucesso
- [ ] Serviço Running
- [ ] Logs mostram "Listening on http://0.0.0.0:3000"
- [ ] Health check retorna OK

---

## 🔧 O QUE FOI CORRIGIDO

### Mudança no Dockerfile

**Arquivo:** `evo-ai-crm-community-main/docker/Dockerfile`

**Adicionado:**
```dockerfile
# Create empty .env file for compatibility (some gems may try to load it)
RUN touch /app/.env
```

**Localização:** Após `WORKDIR /app` e antes de `EXPOSE 3000`

**Motivo:** Algumas gems (como `dotenv-rails`) tentam ler o arquivo `.env` mesmo em produção. Criar um arquivo vazio evita o erro `ENOENT`.

---

## 🎯 VALORES CORRETOS (Lembrete)

### PostgreSQL
```
POSTGRES_PASSWORD=355cbf3375d96724de1f
```

### Redis
```
REDIS_URL=redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379
```

### Build Path
```
evo-ai-crm-community-main
```

---

## ⏱️ TEMPO TOTAL

- Rebuild evo-crm-sidekiq: 2-3 min
- Rebuild evo-crm: 2-3 min
- Verificação: 1 min
- **Total: 5-7 minutos**

---

## 🚨 SE AINDA DER ERRO

### Erro: "no such file or directory"

1. Verificar se o rebuild pegou o código atualizado
2. Verificar se o caminho de build está correto (sem `/`)
3. Verificar se está usando o branch correto (`main`)

### Erro: "WRONGPASS" ou "NOAUTH"

1. Verificar REDIS_URL nas variáveis de ambiente
2. Deve ser: `redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379`

### Erro: "password authentication failed"

1. Verificar POSTGRES_PASSWORD nas variáveis de ambiente
2. Deve ser: `355cbf3375d96724de1f`

---

## ✅ RESULTADO ESPERADO

Após o rebuild, todos os 8 serviços devem estar Running:

```
✅ evo-auth
✅ evo-auth-sidekiq
✅ evo-bot-runtime
✅ evo-core
✅ evo-frontend
✅ evo-processor
✅ evo-crm          ← Deve estar Running
✅ evo-crm-sidekiq  ← Deve estar Running
```

---

## 📞 PRÓXIMOS PASSOS

Após todos os serviços estarem Running:

1. ✅ Testar login no frontend
2. ✅ Criar conversa de teste
3. ✅ Enviar mensagem
4. ✅ Verificar se jobs estão processando
5. ✅ Configurar monitoramento

---

**Última atualização:** 21/04/2026  
**Status:** Dockerfile corrigido e commitado  
**Ação:** Rebuild dos serviços
