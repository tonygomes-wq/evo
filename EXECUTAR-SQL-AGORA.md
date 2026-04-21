# ⚡ EXECUTAR SQL AGORA

## 🚨 PROBLEMA IDENTIFICADO

Você está conectado ao banco de dados **ERRADO**. Precisa conectar ao `evo_community`.

---

## ✅ SOLUÇÃO (3 COMANDOS)

### 📍 PASSO 1: Conectar ao Banco Correto

**No console do PostgreSQL que você tem aberto:**

```sql
\c evo_community
```

**Deve aparecer:**
```
You are now connected to database "evo_community" as user "postgres".
```

---

### 📍 PASSO 2: Executar Script Completo

**Copie e cole TUDO de uma vez:**

```sql
INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING;
INSERT INTO schema_migrations (version) VALUES ('20251117132621') ON CONFLICT DO NOTHING;
INSERT INTO schema_migrations (version) VALUES ('20251117132725') ON CONFLICT DO NOTHING;
```

**Pressione Enter**

**Deve retornar 3 vezes:**
```
INSERT 0 1
```
ou
```
INSERT 0 0
```

---

### 📍 PASSO 3: Verificar (Opcional)

```sql
SELECT * FROM schema_migrations WHERE version IN ('20251114150000', '20251117132621', '20251117132725') ORDER BY version;
```

**Deve mostrar as 3 migrações:**
```
    version     
----------------
 20251114150000
 20251117132621
 20251117132725
```

---

### 📍 PASSO 4: Sair

```sql
\q
```

---

### 📍 PASSO 5: Reiniciar Serviços no Easypanel

1. **evo-crm** → Reiniciar
2. **evo-crm-sidekiq** → Reiniciar

---

## ✅ RESULTADO ESPERADO

Após reiniciar, os logs devem mostrar:

```
✅ Puma starting in cluster mode
✅ Listening on http://0.0.0.0:3000
```

**SEM erros de:**
- ❌ PG::DuplicateColumn
- ❌ PG::DuplicateObject
- ❌ PG::DuplicateTable

---

## 📋 CHECKLIST

- [ ] Conectado ao banco `evo_community`
- [ ] Executado os 3 INSERTs
- [ ] Verificado que as 3 migrações foram inseridas
- [ ] Saído do psql
- [ ] Reiniciado evo-crm
- [ ] Reiniciado evo-crm-sidekiq
- [ ] Verificado logs (sem erros)
- [ ] Todos os serviços Running

---

## 🎯 COMANDOS RESUMIDOS

```sql
-- 1. Conectar ao banco correto
\c evo_community

-- 2. Marcar migrações
INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING;
INSERT INTO schema_migrations (version) VALUES ('20251117132621') ON CONFLICT DO NOTHING;
INSERT INTO schema_migrations (version) VALUES ('20251117132725') ON CONFLICT DO NOTHING;

-- 3. Sair
\q
```

---

## ⏱️ TEMPO TOTAL: 2 MINUTOS

---

**👉 COMECE AGORA: Digite `\c evo_community` no PostgreSQL**

---

**Última atualização:** 21/04/2026
