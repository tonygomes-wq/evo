# ⚡ FAZER AGORA - 5 Minutos

## ✅ CORREÇÃO APLICADA

O código foi corrigido e enviado para o GitHub. Agora você só precisa fazer **REBUILD** dos serviços.

---

## 🎯 AÇÃO (2 PASSOS)

### 📍 PASSO 1: Rebuild evo-crm (2-3 min)

**No Easypanel:**
```
1. Clicar em: evogo
2. Clicar em: evo-crm
3. Clicar em: "Rebuild"
4. Aguardar completar
```

---

### 📍 PASSO 2: Rebuild evo-crm-sidekiq (2-3 min)

**No Easypanel:**
```
1. Clicar em: evo-crm-sidekiq
2. Clicar em: "Rebuild"
3. Aguardar completar
```

---

## ✅ VERIFICAR

### Status dos Serviços

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

### Logs do evo-crm

Deve mostrar:
```
✅ Puma starting in cluster mode
✅ Listening on http://0.0.0.0:3000
```

**NÃO deve mostrar:**
```
❌ PG::DuplicateColumn
❌ sentiment_offensive already exists
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
URL: https://evo.macip.com.br
Email: support@evo-auth-service-community.com
Senha: Password@123
```

---

## 📋 CHECKLIST

- [ ] Rebuild evo-crm executado
- [ ] Rebuild evo-crm-sidekiq executado
- [ ] evo-crm Running
- [ ] evo-crm-sidekiq Running
- [ ] Logs sem erro
- [ ] Health check OK
- [ ] Login funcionando

---

## 🔧 O QUE FOI CORRIGIDO

1. ✅ Arquivo `.env` vazio criado no Dockerfile
2. ✅ Migração corrigida para não dar erro de coluna duplicada
3. ✅ Código commitado e enviado para GitHub

**Agora só falta fazer o rebuild!**

---

## ⏱️ TEMPO: 5 MINUTOS

---

## 🚨 SE DER ERRO

Envie screenshot dos logs e eu ajudo a resolver.

---

**👉 COMECE AGORA: Rebuild do evo-crm no Easypanel**

---

**Última atualização:** 21/04/2026
