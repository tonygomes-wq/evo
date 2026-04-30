# Guia de Aplicação - Migration 000017

**Data:** 2026-04-29  
**Objetivo:** Completar setup multi-tenant com constraints e índices

---

## 📋 Pré-requisitos

✅ Repository filtering implementado (Fase 1 completa)  
✅ Migration 000016 aplicada (colunas account_id criadas)  
✅ Middleware de tenant ativo  
✅ Backup do banco de dados realizado

---

## ⚠️ IMPORTANTE: Backup Obrigatório

**ANTES de aplicar esta migration, faça backup do banco de dados:**

```bash
# Backup via Docker
docker exec evo-postgres pg_dump -U postgres evo_core > backup_pre_migration_000017.sql

# Ou via pg_dump direto
pg_dump -h localhost -U postgres -d evo_core > backup_pre_migration_000017.sql
```

---

## 🔍 Passo 1: Verificar Estado Atual

Execute o script de verificação para ver o estado atual:

```bash
# Via Docker
docker exec -i evo-postgres psql -U postgres -d evo_core < migrations/verify_migration_000017.sql

# Ou via psql direto
psql -h localhost -U postgres -d evo_core -f migrations/verify_migration_000017.sql
```

**O que verificar:**
- ✅ Quantos registros órfãos existem (account_id IS NULL)
- ✅ Se a default account já existe
- ✅ Se constraints já foram aplicadas

---

## 🚀 Passo 2: Aplicar a Migration

### Opção A: Via golang-migrate (Recomendado)

```bash
# Navegar para o diretório do projeto
cd evo-ai-core-service-community-main

# Aplicar migration
migrate -path ./migrations -database "postgresql://postgres:password@localhost:5432/evo_core?sslmode=disable" up
```

### Opção B: Via Docker Compose

```bash
# Parar o serviço
docker-compose -f docker-compose.dokploy.yaml down

# Subir apenas o banco
docker-compose -f docker-compose.dokploy.yaml up -d postgres

# Aguardar banco inicializar
sleep 5

# Aplicar migration manualmente
docker exec -i evo-postgres psql -U postgres -d evo_core < migrations/000017_complete_multi_tenant_setup.up.sql

# Subir todos os serviços
docker-compose -f docker-compose.dokploy.yaml up -d
```

### Opção C: Via psql Direto

```bash
psql -h localhost -U postgres -d evo_core -f migrations/000017_complete_multi_tenant_setup.up.sql
```

---

## ✅ Passo 3: Verificar Sucesso da Migration

Execute novamente o script de verificação:

```bash
docker exec -i evo-postgres psql -U postgres -d evo_core < migrations/verify_migration_000017.sql
```

**Verificações esperadas:**

### 1. Default Account Criada
```
✓ Default account exists
id: 00000000-0000-0000-0000-000000000001
name: Default Account
status: active
```

### 2. Nenhum Registro Órfão
```
table_name                        | orphaned_count | status
----------------------------------|----------------|--------
evo_core_agents                   | 0              | ✓ OK
evo_core_custom_tools             | 0              | ✓ OK
evo_core_api_keys                 | 0              | ✓ OK
evo_core_folders                  | 0              | ✓ OK
evo_core_folder_shares            | 0              | ✓ OK
evo_core_custom_mcp_servers       | 0              | ✓ OK
evo_core_agent_integrations       | 0              | ✓ OK
```

### 3. Foreign Keys Criadas
```
constraint_name                    | table_name
-----------------------------------|---------------------------
fk_agents_account_id               | evo_core_agents
fk_custom_tools_account_id         | evo_core_custom_tools
fk_api_keys_account_id             | evo_core_api_keys
fk_folders_account_id              | evo_core_folders
fk_folder_shares_account_id        | evo_core_folder_shares
fk_custom_mcp_servers_account_id   | evo_core_custom_mcp_servers
fk_agent_integrations_account_id   | evo_core_agent_integrations
```

### 4. NOT NULL Constraints Aplicadas
```
table_name                        | is_nullable | status
----------------------------------|-------------|--------
evo_core_agents                   | NO          | ✓ OK
evo_core_custom_tools             | NO          | ✓ OK
evo_core_api_keys                 | NO          | ✓ OK
evo_core_folders                  | NO          | ✓ OK
evo_core_folder_shares            | NO          | ✓ OK
evo_core_custom_mcp_servers       | NO          | ✓ OK
evo_core_agent_integrations       | NO          | ✓ OK
```

### 5. Índices Compostos Criados
```
Deve listar ~20 índices com padrão:
idx_evo_core_*_account_id_*
```

---

## 🔄 Passo 4: Rebuild e Deploy Docker

Agora que o banco está atualizado, rebuild os containers com o código atualizado:

```bash
# Parar todos os containers
docker-compose -f docker-compose.dokploy.yaml down

# Rebuild com as mudanças de código
docker-compose -f docker-compose.dokploy.yaml build --no-cache

# Subir novamente
docker-compose -f docker-compose.dokploy.yaml up -d

# Verificar logs
docker-compose -f docker-compose.dokploy.yaml logs -f evo-core
```

---

## 🧪 Passo 5: Testar Isolamento de Tenant

### Teste 1: Criar Recurso

```bash
# Login como usuário da Account A
curl -X POST http://localhost:8080/api/v1/agents \
  -H "Authorization: Bearer <token_account_a>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Agent A",
    "description": "Agent for Account A"
  }'

# Resposta esperada: agent criado com account_id da Account A
```

### Teste 2: Tentar Acessar Recurso de Outra Account

```bash
# Login como usuário da Account B
# Tentar acessar agent da Account A
curl -X GET http://localhost:8080/api/v1/agents/<agent_id_from_account_a> \
  -H "Authorization: Bearer <token_account_b>"

# Resposta esperada: 404 Not Found (isolamento funcionando)
```

### Teste 3: Super Admin Acessa Todas as Accounts

```bash
# Login como Super Admin SEM X-Account-Id
curl -X GET http://localhost:8080/api/v1/agents \
  -H "Authorization: Bearer <super_admin_token>"

# Resposta esperada: lista TODOS os agents de TODAS as accounts

# Login como Super Admin COM X-Account-Id
curl -X GET http://localhost:8080/api/v1/agents \
  -H "Authorization: Bearer <super_admin_token>" \
  -H "X-Account-Id: <account_a_id>"

# Resposta esperada: lista apenas agents da Account A
```

---

## 🔙 Rollback (Se Necessário)

Se algo der errado, você pode fazer rollback:

```bash
# Via golang-migrate
migrate -path ./migrations -database "postgresql://postgres:password@localhost:5432/evo_core?sslmode=disable" down 1

# Ou via psql
psql -h localhost -U postgres -d evo_core -f migrations/000017_complete_multi_tenant_setup.down.sql

# Restaurar backup
psql -h localhost -U postgres -d evo_core < backup_pre_migration_000017.sql
```

**⚠️ ATENÇÃO:** O rollback remove constraints e índices, mas **NÃO reverte** a migração de dados. Os registros continuarão com account_id preenchido.

---

## 📊 Monitoramento Pós-Migration

### Verificar Performance das Queries

```sql
-- Verificar uso dos índices
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS index_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_stat_user_indexes
WHERE indexname LIKE '%account_id%'
ORDER BY idx_scan DESC;

-- Queries lentas (se houver)
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    max_time
FROM pg_stat_statements
WHERE query LIKE '%account_id%'
ORDER BY mean_time DESC
LIMIT 10;
```

### Verificar Integridade Referencial

```sql
-- Verificar se há registros com account_id inválido
SELECT 
    'evo_core_agents' AS table_name,
    COUNT(*) AS invalid_count
FROM evo_core_agents a
LEFT JOIN accounts acc ON a.account_id = acc.id
WHERE acc.id IS NULL
UNION ALL
SELECT 
    'evo_core_custom_tools',
    COUNT(*)
FROM evo_core_custom_tools ct
LEFT JOIN accounts acc ON ct.account_id = acc.id
WHERE acc.id IS NULL;
-- Repetir para todas as tabelas

-- Resultado esperado: 0 registros inválidos em todas as tabelas
```

---

## 🎯 Checklist de Validação Final

- [ ] Backup do banco realizado
- [ ] Migration 000017 aplicada com sucesso
- [ ] Verificação pós-migration executada
- [ ] Nenhum registro órfão (account_id IS NULL)
- [ ] Foreign keys criadas (7 constraints)
- [ ] NOT NULL constraints aplicadas (7 tabelas)
- [ ] Índices compostos criados (~20 índices)
- [ ] Docker containers rebuilt e rodando
- [ ] Teste de isolamento: usuário não acessa outra account ✓
- [ ] Teste de Super Admin: acessa todas as accounts ✓
- [ ] Logs do evo-core sem erros
- [ ] Performance das queries aceitável

---

## 📞 Troubleshooting

### Erro: "violates foreign key constraint"

**Causa:** Existem registros com account_id que não existe na tabela accounts.

**Solução:**
```sql
-- Identificar account_ids inválidos
SELECT DISTINCT account_id 
FROM evo_core_agents 
WHERE account_id NOT IN (SELECT id FROM accounts);

-- Migrar para default account
UPDATE evo_core_agents 
SET account_id = '00000000-0000-0000-0000-000000000001'
WHERE account_id NOT IN (SELECT id FROM accounts);
```

### Erro: "column contains null values"

**Causa:** Ainda existem registros com account_id = NULL.

**Solução:**
```sql
-- Verificar quais tabelas têm NULL
SELECT 'evo_core_agents', COUNT(*) FROM evo_core_agents WHERE account_id IS NULL
UNION ALL
SELECT 'evo_core_custom_tools', COUNT(*) FROM evo_core_custom_tools WHERE account_id IS NULL;

-- Migrar para default account
UPDATE evo_core_agents SET account_id = '00000000-0000-0000-0000-000000000001' WHERE account_id IS NULL;
```

### Performance Degradada

**Causa:** Índices não foram criados ou estatísticas desatualizadas.

**Solução:**
```sql
-- Recriar índices
REINDEX TABLE evo_core_agents;
REINDEX TABLE evo_core_custom_tools;
-- Repetir para todas as tabelas

-- Atualizar estatísticas
ANALYZE evo_core_agents;
ANALYZE evo_core_custom_tools;
-- Repetir para todas as tabelas
```

---

## 📚 Próximos Passos

Após completar esta migration:

1. ✅ **Fase 2 COMPLETA** - Migração de banco finalizada
2. ⏳ **Fase 3** - Implementar testes de isolamento
3. ⏳ **Fase 4** - Implementar hierarquia de permissões
4. ⏳ **Fase 5** - Criar endpoints admin

---

**Última Atualização:** 2026-04-29  
**Responsável:** Equipe de Desenvolvimento Evo CRM
