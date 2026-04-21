# 🔍 Comandos de Diagnóstico - Banco de Dados

## Comandos SQL para Verificação e Correção

---

## 📊 Verificações Básicas

### 1. Verificar se o banco existe
```sql
SELECT datname FROM pg_database WHERE datname = 'evo_community';
```

**Resultado esperado:**
```
 datname
--------------
 evo_community
```

### 2. Verificar extensões instaladas
```sql
\c evo_community
SELECT extname, extversion FROM pg_extension;
```

**Resultado esperado:**
```
    extname     | extversion
----------------+------------
 plpgsql        | 1.0
 uuid-ossp      | 1.1
 vector         | 0.5.0
```

### 3. Verificar tabelas criadas
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

### 4. Verificar migrações executadas
```sql
SELECT version 
FROM schema_migrations 
ORDER BY version;
```

---

## 🔧 Correção do Erro de Migração

### Problema: Coluna "sentiment_offensive" já existe

#### Opção 1: Marcar migração como executada (RECOMENDADO)
```sql
INSERT INTO schema_migrations (version) 
VALUES ('20251114150000') 
ON CONFLICT DO NOTHING;
```

#### Opção 2: Verificar se a coluna existe
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'messages' 
  AND column_name = 'sentiment_offensive';
```

#### Opção 3: Remover coluna e reexecutar migração
```sql
-- CUIDADO: Isso remove dados!
ALTER TABLE messages DROP COLUMN IF EXISTS sentiment_offensive;
```

---

## 🔍 Diagnóstico de Conexão

### 1. Verificar usuários e permissões
```sql
SELECT usename, usesuper, usecreatedb 
FROM pg_user 
WHERE usename = 'postgres';
```

### 2. Verificar conexões ativas
```sql
SELECT 
    datname,
    usename,
    application_name,
    client_addr,
    state,
    query
FROM pg_stat_activity
WHERE datname = 'evo_community';
```

### 3. Testar autenticação
```bash
# No terminal do servidor PostgreSQL
psql -h evogo_postgres -U postgres -d evo_community -c "SELECT version();"
```

**Se pedir senha, usar:** `355cbf3375d96724de1f`

---

## 📋 Verificação de Tabelas Específicas

### 1. Verificar tabela messages
```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'messages'
ORDER BY ordinal_position;
```

### 2. Verificar tabela accounts
```sql
SELECT id, name, created_at 
FROM accounts 
LIMIT 5;
```

### 3. Verificar tabela users
```sql
SELECT id, email, name, created_at 
FROM users 
LIMIT 5;
```

### 4. Verificar tabela conversations
```sql
SELECT id, account_id, inbox_id, status, created_at 
FROM conversations 
ORDER BY created_at DESC 
LIMIT 5;
```

---

## 🔧 Comandos de Manutenção

### 1. Reindexar banco de dados
```sql
REINDEX DATABASE evo_community;
```

### 2. Analisar tabelas
```sql
ANALYZE;
```

### 3. Vacuum (limpeza)
```sql
VACUUM ANALYZE;
```

### 4. Verificar tamanho do banco
```sql
SELECT 
    pg_size_pretty(pg_database_size('evo_community')) as size;
```

### 5. Verificar tamanho das tabelas
```sql
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 10;
```

---

## 🔍 Diagnóstico de Migrações

### 1. Listar todas as migrações executadas
```sql
SELECT version, 
       to_timestamp(version::bigint/1000000) as migration_date
FROM schema_migrations
ORDER BY version;
```

### 2. Verificar última migração
```sql
SELECT version 
FROM schema_migrations 
ORDER BY version DESC 
LIMIT 1;
```

### 3. Contar migrações
```sql
SELECT COUNT(*) as total_migrations 
FROM schema_migrations;
```

### 4. Verificar se migração específica foi executada
```sql
SELECT EXISTS(
    SELECT 1 
    FROM schema_migrations 
    WHERE version = '20251114150000'
) as migration_exists;
```

---

## 🔧 Correções Específicas

### 1. Resetar sequências (se IDs estiverem desalinhados)
```sql
-- Para todas as tabelas
SELECT 'SELECT SETVAL(' ||
       quote_literal(quote_ident(PGT.schemaname) || '.' || quote_ident(S.relname)) ||
       ', COALESCE(MAX(' ||quote_ident(C.attname)|| '), 1) ) FROM ' ||
       quote_ident(PGT.schemaname)|| '.'||quote_ident(T.relname)|| ';'
FROM pg_class AS S,
     pg_depend AS D,
     pg_class AS T,
     pg_attribute AS C,
     pg_tables AS PGT
WHERE S.relkind = 'S'
    AND S.oid = D.objid
    AND D.refobjid = T.oid
    AND D.refobjid = C.attrelid
    AND D.refobjsubid = C.attnum
    AND T.relname = PGT.tablename
    AND PGT.schemaname = 'public'
ORDER BY S.relname;
```

### 2. Criar extensões (se não existirem)
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;
```

### 3. Verificar e corrigir permissões
```sql
-- Dar permissões ao usuário postgres
GRANT ALL PRIVILEGES ON DATABASE evo_community TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
```

---

## 🔍 Comandos via Rails Console

### Acessar Rails Console
```bash
# No container evo-crm
bundle exec rails console
```

### Comandos úteis no console

#### 1. Verificar conexão com banco
```ruby
ActiveRecord::Base.connection.execute("SELECT version()").first
```

#### 2. Verificar migrações pendentes
```ruby
ActiveRecord::Migration.check_pending!
```

#### 3. Listar todas as migrações
```ruby
ActiveRecord::Base.connection.migration_context.migrations.each do |m|
  puts "#{m.version} - #{m.name}"
end
```

#### 4. Verificar status das migrações
```ruby
ActiveRecord::Base.connection.migration_context.migrations_status.each do |status, version, name|
  puts "#{status} #{version} #{name}"
end
```

#### 5. Marcar migração como executada
```ruby
ActiveRecord::Base.connection.execute(
  "INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING"
)
```

#### 6. Verificar se coluna existe
```ruby
ActiveRecord::Base.connection.column_exists?(:messages, :sentiment_offensive)
```

#### 7. Remover coluna
```ruby
ActiveRecord::Base.connection.remove_column(:messages, :sentiment_offensive) if 
  ActiveRecord::Base.connection.column_exists?(:messages, :sentiment_offensive)
```

#### 8. Executar migração específica
```ruby
ActiveRecord::MigrationContext.new("db/migrate").up(20251114150000)
```

---

## 🔍 Comandos via Rails Runner

### Executar comando único
```bash
bundle exec rails runner "puts ActiveRecord::Base.connection.execute('SELECT version()').first"
```

### Verificar conexão Redis
```bash
bundle exec rails runner "puts Redis.new(url: ENV['REDIS_URL']).ping"
```

### Verificar variáveis de ambiente
```bash
bundle exec rails runner "puts ENV['POSTGRES_HOST']"
bundle exec rails runner "puts ENV['POSTGRES_DATABASE']"
bundle exec rails runner "puts ENV['REDIS_URL']"
```

### Criar usuário admin (se necessário)
```bash
bundle exec rails runner "
  User.create!(
    email: 'admin@macip.com.br',
    password: 'Admin@123',
    name: 'Admin',
    confirmed_at: Time.now
  )
"
```

---

## 📊 Queries de Monitoramento

### 1. Verificar atividade do banco
```sql
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    state_change,
    query
FROM pg_stat_activity
WHERE datname = 'evo_community'
  AND state != 'idle'
ORDER BY query_start;
```

### 2. Verificar locks
```sql
SELECT 
    l.pid,
    l.mode,
    l.granted,
    a.query
FROM pg_locks l
JOIN pg_stat_activity a ON l.pid = a.pid
WHERE a.datname = 'evo_community';
```

### 3. Verificar queries lentas
```sql
SELECT 
    pid,
    now() - query_start as duration,
    query,
    state
FROM pg_stat_activity
WHERE state != 'idle'
  AND datname = 'evo_community'
ORDER BY duration DESC;
```

### 4. Estatísticas de tabelas
```sql
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes,
    n_live_tup as live_rows,
    n_dead_tup as dead_rows
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY n_live_tup DESC;
```

---

## 🔧 Script Completo de Verificação

### Executar no PostgreSQL
```sql
-- Script de verificação completa
\c evo_community

-- 1. Verificar extensões
SELECT 'Extensões instaladas:' as info;
SELECT extname, extversion FROM pg_extension;

-- 2. Verificar migrações
SELECT 'Total de migrações:' as info;
SELECT COUNT(*) FROM schema_migrations;

-- 3. Verificar tabelas
SELECT 'Tabelas criadas:' as info;
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';

-- 4. Verificar última migração
SELECT 'Última migração:' as info;
SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1;

-- 5. Verificar se migração problemática existe
SELECT 'Migração 20251114150000 executada:' as info;
SELECT EXISTS(SELECT 1 FROM schema_migrations WHERE version = '20251114150000');

-- 6. Verificar coluna problemática
SELECT 'Coluna sentiment_offensive existe:' as info;
SELECT EXISTS(
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'messages' 
      AND column_name = 'sentiment_offensive'
);

-- 7. Verificar conexões ativas
SELECT 'Conexões ativas:' as info;
SELECT COUNT(*) FROM pg_stat_activity WHERE datname = 'evo_community';

-- 8. Verificar tamanho do banco
SELECT 'Tamanho do banco:' as info;
SELECT pg_size_pretty(pg_database_size('evo_community'));
```

---

## 📝 Notas Importantes

1. **Backup antes de qualquer alteração:**
   ```bash
   pg_dump -h evogo_postgres -U postgres evo_community > backup_$(date +%Y%m%d_%H%M%S).sql
   ```

2. **Restaurar backup (se necessário):**
   ```bash
   psql -h evogo_postgres -U postgres evo_community < backup_20260421_120000.sql
   ```

3. **Senha do PostgreSQL:**
   - Sempre usar: `355cbf3375d96724de1f`
   - Verificar se não tem espaços ou caracteres extras

4. **Conexão via psql:**
   ```bash
   PGPASSWORD=355cbf3375d96724de1f psql -h evogo_postgres -U postgres -d evo_community
   ```

---

**Última atualização:** 21/04/2026
**Uso:** Diagnóstico e correção de problemas no banco de dados
