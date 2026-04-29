# Evo Core Service — Análise de Multi-Tenancy

## Status Atual

> **⚠️ Multi-tenancy NÃO está implementado no evo-core (Community Edition).**

A Community Edition é declaradamente **single-tenant** (uma organização). Porém, se você precisar suportar múltiplos clientes/organizações isolados, esta análise documenta o roadmap de implementação.

---

## Diagnóstico

### O que existe hoje

| Componente | Status | Observação |
|------------|--------|------------|
| Autenticação via EvoAuth | ✅ Implementado | Bearer Token validado |
| Contexto de usuário injetado | ✅ Implementado | user_id, email, accounts |
| Isolamento de dados por account | ❌ Não implementado | Todos os dados são globais |
| Filtro por account_id nas queries | ❌ Não implementado | Sem WHERE account_id = ? |
| account_id nas tabelas | ❌ Não implementado | Sem coluna nas tabelas |
| Middleware de tenant context | ❌ Não implementado | Arquivo não existe |

### Evidência no código

O `evo-auth` já retorna `accounts` para cada usuário autenticado:
```go
// Dados disponíveis no contexto após autenticação:
user_id  : UUID do usuário
email    : email do usuário
accounts : []EvoAuthAccount  // ← lista de contas do usuário
           // MAS não são usados para filtrar dados no banco
```

As tabelas existentes não possuem `account_id`:
```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'evo_core_agents';
-- Resultado: id, name, description, type, created_at, updated_at
-- Sem account_id!
```

---

## Plano de Implementação

O spec completo está em [`.kiro/specs/multi-tenant-hierarchy/requirements.md`](../.kiro/specs/multi-tenant-hierarchy/requirements.md).

### Fase 1 — Schema do Banco (Requirement 1 + 7 + 8)

#### Migração para adicionar `account_id`

```sql
-- migrations/XXXX_add_account_id_to_tables.up.sql

-- 1. Agents
ALTER TABLE evo_core_agents
  ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;
CREATE INDEX idx_evo_core_agents_account_id_id ON evo_core_agents(account_id, id);
CREATE INDEX idx_evo_core_agents_account_id_name ON evo_core_agents(account_id, name);

-- 2. Custom Tools
ALTER TABLE evo_core_custom_tools
  ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;
CREATE INDEX idx_evo_core_custom_tools_account_id ON evo_core_custom_tools(account_id, id);

-- 3. Folders
ALTER TABLE evo_core_folders
  ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;
CREATE INDEX idx_evo_core_folders_account_id ON evo_core_folders(account_id, id);

-- 4. API Keys
ALTER TABLE evo_core_api_keys
  ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;
CREATE INDEX idx_evo_core_api_keys_account_id ON evo_core_api_keys(account_id, id);

-- 5. Custom MCP Servers
ALTER TABLE evo_core_custom_mcp_servers
  ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;
CREATE INDEX idx_evo_core_custom_mcp_servers_account_id ON evo_core_custom_mcp_servers(account_id, id);

-- 6. Folder Shares
ALTER TABLE evo_core_folder_shares
  ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;
CREATE INDEX idx_evo_core_folder_shares_account_id ON evo_core_folder_shares(account_id, id);

-- 7. Agent Integrations
ALTER TABLE evo_core_agent_integrations
  ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;
CREATE INDEX idx_evo_core_agent_integrations_account_id ON evo_core_agent_integrations(account_id, id);
```

#### Updates nos Models Go

```go
// pkg/agent/model/agent.go
type Agent struct {
    ID          uuid.UUID `gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
    AccountID   uuid.UUID `gorm:"type:uuid;not null;index" json:"account_id"` // NOVO
    Name        string    `gorm:"type:varchar(255);not null" json:"name"`
    Description string    `gorm:"type:text" json:"description"`
    // ... outros campos
}
```

---

### Fase 2 — Middleware de Tenant (Requirement 2 + 3)

```go
// internal/middleware/tenant.go

func TenantMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        accounts := getAccountsFromContext(c)
        if len(accounts) == 0 {
            c.AbortWithStatusJSON(403, gin.H{"error": "No account associated with user"})
            return
        }

        // Usuário super_admin pode bypassar
        if isSuperAdmin(c) {
            accountID := c.GetHeader("X-Account-Id")
            if accountID == "" {
                // Super admin sem header = acesso global
                c.Set("bypass_tenant_filter", true)
            } else {
                c.Set("account_id", uuid.MustParse(accountID))
            }
            c.Next()
            return
        }

        // Usuário normal — usa primeira conta ativa
        accountID := accounts[0].ID

        // Permite override via header (valida acesso)
        if headerID := c.GetHeader("X-Account-Id"); headerID != "" {
            parsed, err := uuid.Parse(headerID)
            if err != nil || !hasAccountAccess(accounts, parsed) {
                c.AbortWithStatusJSON(403, gin.H{"error": "Invalid or unauthorized account access"})
                return
            }
            accountID = parsed
        }

        c.Set("account_id", accountID)
        c.Next()
    }
}
```

**Registrar após EvoAuth middleware em `cmd/api/main.go`:**
```go
v1 := router.Group("/api/v1")
v1.Use(evoAuthMiddleware.GetEvoAuthMiddleware())
v1.Use(middleware.TenantMiddleware()) // ← ADICIONAR AQUI
```

---

### Fase 3 — Repository Layer (Requirement 6)

Todos os repositories devem filtrar por `account_id`:

```go
// pkg/agent/repository/agent_repository.go

func (r *agentRepository) FindAll(ctx context.Context) ([]model.Agent, error) {
    accountID := utils.GetAccountIDFromContext(ctx)
    var agents []model.Agent
    query := r.db.Model(&model.Agent{})
    if accountID != uuid.Nil {
        query = query.Where("account_id = ?", accountID)
    }
    return agents, query.Find(&agents).Error
}

func (r *agentRepository) FindByID(ctx context.Context, id uuid.UUID) (*model.Agent, error) {
    accountID := utils.GetAccountIDFromContext(ctx)
    var agent model.Agent
    query := r.db.Where("id = ?", id)
    if accountID != uuid.Nil {
        query = query.Where("account_id = ?", accountID)
    }
    err := query.First(&agent).Error
    if errors.Is(err, gorm.ErrRecordNotFound) {
        return nil, errors.New("resource not found")
    }
    return &agent, err
}

func (r *agentRepository) Create(ctx context.Context, agent *model.Agent) error {
    agent.AccountID = utils.GetAccountIDFromContext(ctx)
    return r.db.Create(agent).Error
}
```

---

### Fase 4 — Hierarquia de Permissões (Requirements 3-5)

| Role | Acesso |
|------|--------|
| `super_admin` | Todos os dados, todas as accounts |
| `account_owner` | CRUD completo na sua account |
| `account_user` (viewer) | Apenas leitura (GET) |
| `account_user` (editor) | Leitura e escrita (GET, POST, PUT, PATCH) |
| `account_user` (account_admin) | Tudo exceto gerenciamento de usuários |

---

### Fase 5 — Novos Endpoints Admin (Requirement 3 + 4)

```
# Super Admin
GET    /api/v1/admin/accounts              → listar todas as accounts
POST   /api/v1/admin/accounts              → criar account
GET    /api/v1/admin/accounts/:id/stats    → estatísticas da account
PATCH  /api/v1/admin/accounts/:id/status   → habilitar/desabilitar account
GET    /api/v1/admin/accounts/:id/resources-count → preview de deleção
GET    /api/v1/admin/audit-logs            → logs de auditoria
GET    /api/v1/admin/performance/slow-queries

# Account Owner
GET    /api/v1/account/users               → listar usuários da account
POST   /api/v1/account/users               → convidar usuário
PATCH  /api/v1/account/users/:id/role      → alterar papel do usuário
DELETE /api/v1/account/users/:id           → remover usuário
GET    /api/v1/account/stats               → estatísticas da account

# Account User
GET    /api/v1/account/my-permissions      → ver permissões do usuário atual
```

---

## Estratégia de Migração de Dados

Para ambientes existentes com dados sem `account_id`:

```sql
-- 1. Criar account padrão (se não existir)
INSERT INTO accounts (id, name, status, created_at, updated_at)
VALUES (gen_random_uuid(), 'Default Account', 'active', NOW(), NOW())
ON CONFLICT DO NOTHING
RETURNING id;

-- 2. Adicionar coluna como nullable temporariamente
ALTER TABLE evo_core_agents ADD COLUMN account_id UUID;

-- 3. Atribuir account padrão a todos os registros existentes
UPDATE evo_core_agents SET account_id = '<id_da_account_padrao>'
WHERE account_id IS NULL;

-- 4. Verificar que todos os registros foram atualizados
SELECT COUNT(*) FROM evo_core_agents WHERE account_id IS NULL;
-- Deve retornar 0

-- 5. Aplicar constraint NOT NULL e FK
ALTER TABLE evo_core_agents
  ALTER COLUMN account_id SET NOT NULL,
  ADD CONSTRAINT fk_agents_account_id
    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;
```

---

## Impacto por Requirement (do spec)

| Req | Título | Esforço | Prioridade |
|-----|--------|---------|------------|
| 1 | Database Schema | Médio | 🔴 Crítico |
| 2 | Tenant Middleware | Médio | 🔴 Crítico |
| 3 | Super Admin Bypass | Médio | 🟡 Alta |
| 4 | Account Owner Permissions | Médio | 🟡 Alta |
| 5 | Account User Permissions | Alto | 🟡 Alta |
| 6 | Repository Filtering | Alto | 🔴 Crítico |
| 7 | Model Updates | Baixo | 🔴 Crítico |
| 8 | Data Migration | Médio | 🔴 Crítico |
| 9 | Cross-Tenant Prevention | Médio | 🔴 Crítico |
| 10 | Cascade Deletion | Baixo | 🟡 Alta |
| 11 | Rate Limiting Per Tenant | Médio | 🟢 Média |
| 12 | Audit Logging | Médio | 🟢 Média |
| 13 | Multi-Tenancy Testing | Alto | 🟡 Alta |
| 14 | Documentation | Médio | 🟢 Média |
| 15 | Performance Optimization | Médio | 🟢 Média |

**Estimativa total**: 2-3 semanas de desenvolvimento

---

## Referências

- Spec completo: [`.kiro/specs/multi-tenant-hierarchy/requirements.md`](../.kiro/specs/multi-tenant-hierarchy/requirements.md)
- Análise de deploy: [`ANALISE_MULTI_TENANT_EASYPANEL.md`](../ANALISE_MULTI_TENANT_EASYPANEL.md)
- Análise do sistema: [`ANALISE_SISTEMA.md`](../ANALISE_SISTEMA.md)
