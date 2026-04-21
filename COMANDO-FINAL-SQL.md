# ⚡ COMANDO FINAL - Última Migração

## ✅ PROGRESSO ATÉ AGORA

Você já executou com sucesso:
- ✅ `20251114150000` - sentiment_offensive
- ✅ `20251117132621` - contact_type_enum  
- ✅ `20251117132725` - contact_companies

---

## 🎯 FALTA APENAS 1 MIGRAÇÃO

**No PostgreSQL (você já está conectado):**

```sql
INSERT INTO schema_migrations (version) VALUES ('20251117181534') ON CONFLICT DO NOTHING;
```

**Pressione Enter**

---

## 📍 DEPOIS: Sair e Reiniciar

### 1. Sair do PostgreSQL

```sql
\q
```

### 2. Reiniciar Serviços no Easypanel

**evo-crm:**
```
1. Easypanel → evogo → evo-crm
2. Clicar em "Reiniciar" (Restart)
3. Aguardar 30 segundos
```

**evo-crm-sidekiq:**
```
1. Easypanel → evogo → evo-crm-sidekiq
2. Clicar em "Reiniciar" (Restart)
3. Aguardar 30 segundos
```

---

## ✅ RESULTADO ESPERADO

### Logs do evo-crm

```
✅ [dotenv] Loaded .env
✅ Oj JSON serializer initialized
✅ BMS INIT: Initializing BMS email provider
✅ MAILER CONFIG: Using SMTP/Sendmail delivery method
✅ Puma starting in cluster mode
✅ Listening on http://0.0.0.0:3000
```

**SEM ERROS DE:**
- ❌ PG::DuplicateColumn
- ❌ PG::DuplicateObject
- ❌ PG::DuplicateTable
- ❌ bin/rails aborted!

### Logs do evo-crm-sidekiq

```
✅ [dotenv] Loaded .env
✅ Booting Sidekiq
✅ Running in ruby
✅ Starting processing
```

---

## 🎯 STATUS FINAL DOS SERVIÇOS

Todos devem estar **Running**:

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

## 🧪 TESTAR O SISTEMA

### 1. Health Check

```bash
curl https://api.macip.com.br/health/live
```

**Deve retornar:**
```json
{"status":"ok"}
```

### 2. Login

```
URL: https://evo.macip.com.br
Email: support@evo-auth-service-community.com
Senha: Password@123
```

### 3. Criar Conversa

1. Fazer login
2. Criar nova conversa
3. Enviar mensagem
4. Verificar resposta

---

## 📋 CHECKLIST FINAL

### SQL
- [x] Migração 1: `20251114150000` ✅
- [x] Migração 2: `20251117132621` ✅
- [x] Migração 3: `20251117132725` ✅
- [ ] Migração 4: `20251117181534` ← **EXECUTAR AGORA**

### Serviços
- [ ] Saiu do PostgreSQL
- [ ] evo-crm reiniciado
- [ ] evo-crm-sidekiq reiniciado
- [ ] evo-crm: Running
- [ ] evo-crm-sidekiq: Running
- [ ] Logs sem erros

### Testes
- [ ] Health check OK
- [ ] Login funcionando
- [ ] Dashboard carregando
- [ ] Conversa criada
- [ ] Mensagem enviada

---

## 🔧 CORREÇÕES APLICADAS NO CÓDIGO

Todas as 4 migrações problemáticas foram corrigidas para serem idempotentes:

1. ✅ `20251114150000` - Verifica se colunas existem antes de criar
2. ✅ `20251117132621` - Verifica se tipo ENUM existe antes de criar
3. ✅ `20251117132725` - Verifica se tabela existe antes de criar
4. ✅ `20251117181534` - Verifica se colunas existem antes de criar

**Código commitado e enviado para GitHub!**

---

## ⏱️ TEMPO RESTANTE

- Executar SQL: 10 segundos
- Sair do psql: 5 segundos
- Reiniciar serviços: 1 minuto
- Verificar: 30 segundos
- **Total: 2 minutos**

---

## 🎉 APÓS CONCLUSÃO

Sistema completamente operacional:
- ✅ Todas as migrações executadas
- ✅ Todos os serviços Running
- ✅ Sem erros nos logs
- ✅ Pronto para produção

---

## 📝 COMANDO PARA EXECUTAR AGORA

**No PostgreSQL:**

```sql
INSERT INTO schema_migrations (version) VALUES ('20251117181534') ON CONFLICT DO NOTHING;
```

**Depois:**

```sql
\q
```

**Depois:**
- Reiniciar evo-crm
- Reiniciar evo-crm-sidekiq

---

**👉 Execute o comando SQL agora!**

---

**Última atualização:** 21/04/2026  
**Status:** Última migração pendente  
**Tempo:** 2 minutos para conclusão
