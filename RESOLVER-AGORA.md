# ⚡ RESOLVER AGORA - 2 Minutos

## 🎯 PROBLEMA

Erro de migração impedindo os serviços de iniciarem:
```
column "sentiment_offensive" already exists
```

---

## ✅ SOLUÇÃO (3 PASSOS)

### 📍 PASSO 1: Abrir Console (30 segundos)

**No Easypanel:**
```
1. Clicar em: evogo
2. Clicar em: evo-crm
3. Clicar em: Console (ou Terminal)
4. Selecionar: Bash
```

---

### 📍 PASSO 2: Executar Comando (30 segundos)

**Copie este comando:**

```bash
bundle exec rails runner "ActiveRecord::Base.connection.execute(\"INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING\")"
```

**Cole no console e pressione Enter**

**Aguarde terminar (não deve dar erro)**

---

### 📍 PASSO 3: Reiniciar Serviços (1 minuto)

**Fechar o console**

**Reiniciar evo-crm:**
```
1. Voltar para evo-crm
2. Clicar em "Reiniciar" (Restart)
3. Aguardar 30 segundos
```

**Reiniciar evo-crm-sidekiq:**
```
1. Ir para evo-crm-sidekiq
2. Clicar em "Reiniciar" (Restart)
3. Aguardar 30 segundos
```

---

## ✅ VERIFICAR

### Logs do evo-crm

Deve mostrar:
```
✅ Puma starting in cluster mode
✅ Listening on http://0.0.0.0:3000
```

### Logs do evo-crm-sidekiq

Deve mostrar:
```
✅ Booting Sidekiq
✅ Starting processing
```

### Status dos Serviços

Todos devem estar **Running**:
```
✅ evo-auth
✅ evo-auth-sidekiq
✅ evo-bot-runtime
✅ evo-core
✅ evo-frontend
✅ evo-processor
✅ evo-crm          ← Deve estar Running agora
✅ evo-crm-sidekiq  ← Deve estar Running agora
```

---

## 🎯 TESTAR

### Health Check

```bash
curl https://api.macip.com.br/health/live
```

**Deve retornar:**
```json
{"status":"ok"}
```

### Login

```
1. Acessar: https://evo.macip.com.br
2. Email: support@evo-auth-service-community.com
3. Senha: Password@123
```

---

## 📋 CHECKLIST

- [ ] Passo 1: Console aberto
- [ ] Passo 2: Comando executado
- [ ] Passo 3: Serviços reiniciados
- [ ] evo-crm Running
- [ ] evo-crm-sidekiq Running
- [ ] Health check OK
- [ ] Login funcionando

---

## 🚨 SE DER ERRO

### "command not found: bundle"
→ Você está no console errado
→ Certifique-se de estar no console do **evo-crm**

### Serviço não reinicia
→ Verificar logs para ver o erro
→ Enviar screenshot dos logs

---

## ⏱️ TEMPO TOTAL: 2 MINUTOS

---

**👉 COMECE AGORA: Abra o console do evo-crm no Easypanel**

---

**Última atualização:** 21/04/2026
