# 🔧 Correção Via PostgreSQL Direto

## 🎯 PROBLEMA

O serviço evo-crm fica reiniciando continuamente devido ao erro de migração, impossibilitando acesso ao console Rails.

---

## ✅ SOLUÇÃO: Conectar Direto no PostgreSQL

### Opção 1: Via Console do Serviço PostgreSQL no Easypanel

#### Passo 1: Acessar Console do PostgreSQL

**No Easypanel:**
```
1. Projeto: evogo
2. Procurar serviço: evogo_postgres (ou postgres)
3. Clicar em: Console
4. Selecionar: Bash ou Sh
```

#### Passo 2: Conectar ao Banco

**No console, executar:**
```bash
psql -U postgres -d evo_community
```

**Se pedir senha, usar:** `355cbf3375d96724de1f`

#### Passo 3: Executar SQL

**Copiar e colar:**
```sql
INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING;
```

**Pressionar Enter**

#### Passo 4: Sair do psql

```sql
\q
```

#### Passo 5: Reiniciar Serviços

1. Fechar console
2. Reiniciar **evo-crm**
3. Reiniciar **evo-crm-sidekiq**

---

### Opção 2: Via Ferramenta de Banco de Dados Externa

Se você tem acesso externo ao PostgreSQL:

#### Conectar com suas credenciais:
```
Host: evogo_postgres (ou IP externo)
Port: 5432
Database: evo_community
Username: postgres
Password: 355cbf3375d96724de1f
```

#### Executar SQL:
```sql
INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING;
```

---

### Opção 3: Modificar Dockerfile para Pular Migração

Se não conseguir acessar o PostgreSQL, vamos modificar o código para ignorar essa migração.

#### Criar arquivo de migração modificado

Vamos criar uma versão da migração que verifica se a coluna já existe antes de tentar criá-la.

---

## 🎯 RECOMENDAÇÃO: Opção 1 (PostgreSQL Direto)

É a mais rápida e segura.

---

## 📋 PASSO A PASSO DETALHADO - OPÇÃO 1

### 1. Encontrar Serviço PostgreSQL

**No Easypanel, procurar por:**
- `evogo_postgres`
- `postgres`
- Ou qualquer serviço de banco de dados

### 2. Abrir Console

```
Clicar no serviço PostgreSQL → Console → Bash (ou Sh)
```

### 3. Conectar ao Banco

```bash
psql -U postgres -d evo_community
```

**Você verá algo como:**
```
evo_community=#
```

### 4. Executar Comando SQL

```sql
INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING;
```

**Deve retornar:**
```
INSERT 0 1
```
ou
```
INSERT 0 0
```

### 5. Verificar (Opcional)

```sql
SELECT * FROM schema_migrations WHERE version = '20251114150000';
```

**Deve retornar:**
```
    version     
----------------
 20251114150000
```

### 6. Sair

```sql
\q
```

### 7. Reiniciar Serviços

- evo-crm → Reiniciar
- evo-crm-sidekiq → Reiniciar

---

## ✅ VERIFICAÇÃO

Após reiniciar, os logs devem mostrar:

### evo-crm
```
✅ Puma starting in cluster mode
✅ Listening on http://0.0.0.0:3000
```

**NÃO deve mais aparecer:**
```
❌ PG::DuplicateColumn
❌ sentiment_offensive already exists
```

### evo-crm-sidekiq
```
✅ Booting Sidekiq
✅ Starting processing
```

---

## 🚨 SE NÃO ENCONTRAR SERVIÇO POSTGRESQL

O PostgreSQL pode estar:
1. Em outro projeto no Easypanel
2. Hospedado externamente
3. Com nome diferente

**Verificar:**
- Variável `POSTGRES_HOST` do evo-crm
- Deve indicar onde está o PostgreSQL

---

## 📝 COMANDOS RESUMIDOS

### Conectar:
```bash
psql -U postgres -d evo_community
```

### Executar:
```sql
INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING;
```

### Sair:
```sql
\q
```

---

## ⏱️ TEMPO TOTAL

- Encontrar serviço PostgreSQL: 1 min
- Conectar e executar SQL: 1 min
- Reiniciar serviços: 1 min
- **Total: 3 minutos**

---

## 📞 SE NÃO CONSEGUIR

Vou criar a **Opção 3**: modificar o Dockerfile para ignorar essa migração automaticamente.

---

**Última atualização:** 21/04/2026  
**Prioridade:** CRÍTICA
