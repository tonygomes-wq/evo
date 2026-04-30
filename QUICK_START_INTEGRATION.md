# Quick Start - Integração Multi-Tenant

**Guia rápido para integrar o sistema multi-tenant no Evo CRM**

---

## ⚡ Passos Rápidos

### 1. Aplicar Migration (5 minutos)

```bash
# Backup
docker exec evo-postgres pg_dump -U postgres evo_core > backup_$(date +%Y%m%d_%H%M%S).sql

# Aplicar migration
cd evo-ai-core-service-community-main
docker exec -i evo-postgres psql -U postgres -d evo_core < migrations/000017_complete_multi_tenant_setup.up.sql

# Verificar
docker exec -i evo-postgres psql -U postgres -d evo_core < migrations/verify_migration_000017.sql
```

**Resultado esperado:**
- ✅ Default account criada
- ✅ 0 registros órfãos
- ✅ 7 foreign keys
- ✅ 7 NOT NULL constraints
- ✅ ~20 índices

---

### 2. Registrar Rotas Admin (2 minutos)

Edite `cmd/api/main.go`:

```go
package main

import (
    // ... imports existentes ...
    "evo-ai-core-service/internal/routes"
    "evo-ai-core-service/internal/middleware"
)

func main() {
    // ... código existente até criar router ...

    // Criar middleware de autorização
    authMiddleware := middleware.NewAuthorizationMiddleware()

    // Grupo v1
    v1 := router.Group("/api/v1")
    v1.Use(evoAuthMiddleware.GetEvoAuthMiddleware())
    v1.Use(tenantMiddleware.GetTenantMiddleware())

    // ✅ ADICIONAR: Registrar rotas admin
    routes.SetupAdminRoutes(v1, db, authMiddleware)

    // ... resto do código existente ...
}
```

---

### 3. Proteger Rotas Existentes (10 minutos)

Edite os arquivos de rotas existentes para adicionar middlewares de autorização:

**Exemplo: `internal/routes/agent_routes.go`**

```go
package routes

import (
    "evo-ai-core-service/internal/handler"
    "evo-ai-core-service/internal/middleware"
    "github.com/gin-gonic/gin"
    "gorm.io/gorm"
)

func SetupAgentRoutes(router *gin.RouterGroup, db *gorm.DB, authMiddleware *middleware.AuthorizationMiddleware) {
    agentHandler := handler.NewAgentHandler(db)

    agentGroup := router.Group("/agents")
    {
        // Listar - qualquer usuário autenticado
        agentGroup.GET("", authMiddleware.RequireViewer(), agentHandler.List)
        
        // Obter por ID - qualquer usuário autenticado
        agentGroup.GET("/:id", authMiddleware.RequireViewer(), agentHandler.GetByID)
        
        // Criar - editor ou superior
        agentGroup.POST("", authMiddleware.RequireEditor(), agentHandler.Create)
        
        // Atualizar - editor ou superior
        agentGroup.PUT("/:id", authMiddleware.RequireEditor(), agentHandler.Update)
        agentGroup.PATCH("/:id", authMiddleware.RequireEditor(), agentHandler.Update)
        
        // Deletar - account_admin ou superior
        agentGroup.DELETE("/:id", authMiddleware.RequireAccountAdmin(), agentHandler.Delete)
    }
}
```

**Repita para:**
- `custom_tool_routes.go`
- `api_key_routes.go`
- `folder_routes.go`
- `folder_share_routes.go`
- `custom_mcp_server_routes.go`
- `agent_integration_routes.go`

---

### 4. Rebuild e Deploy (5 minutos)

```bash
# Parar containers
docker-compose -f docker-compose.dokploy.yaml down

# Rebuild
docker-compose -f docker-compose.dokploy.yaml build --no-cache

# Subir
docker-compose -f docker-compose.dokploy.yaml up -d

# Verificar logs
docker-compose -f docker-compose.dokploy.yaml logs -f evo-core
```

**Logs esperados:**
```
✓ Database connected
✓ Migrations applied
✓ Server started on :8080
```

---

## 🧪 Testes Rápidos

### Teste 1: Endpoints Admin (Super Admin)

```bash
# Listar accounts
curl -X GET http://localhost:8080/api/v1/admin/accounts \
  -H "Authorization: Bearer <super_admin_token>"

# Criar account
curl -X POST http://localhost:8080/api/v1/admin/accounts \
  -H "Authorization: Bearer <super_admin_token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Company", "status": "active"}'
```

### Teste 2: Isolamento de Tenant

```bash
# Criar agent na Account A
curl -X POST http://localhost:8080/api/v1/agents \
  -H "Authorization: Bearer <token_account_a>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Agent A", "type": "chat"}'

# Tentar acessar da Account B (deve falhar)
curl -X GET http://localhost:8080/api/v1/agents/<agent_id> \
  -H "Authorization: Bearer <token_account_b>"
# Esperado: 404 Not Found
```

### Teste 3: Permissões

```bash
# Viewer tenta criar (deve falhar)
curl -X POST http://localhost:8080/api/v1/agents \
  -H "Authorization: Bearer <viewer_token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test", "type": "chat"}'
# Esperado: 403 Forbidden

# Editor cria (deve funcionar)
curl -X POST http://localhost:8080/api/v1/agents \
  -H "Authorization: Bearer <editor_token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test", "type": "chat"}'
# Esperado: 201 Created
```

---

## 📊 Verificação de Sucesso

### Checklist Rápido

- [ ] Migration aplicada sem erros
- [ ] Rotas admin registradas
- [ ] Middlewares aplicados nas rotas
- [ ] Docker rebuild concluído
- [ ] Servidor iniciou sem erros
- [ ] Endpoint admin funciona
- [ ] Isolamento de tenant funciona
- [ ] Permissões funcionam

### Comandos de Verificação

```bash
# 1. Verificar banco
docker exec -i evo-postgres psql -U postgres -d evo_core -c "SELECT COUNT(*) FROM accounts;"
# Esperado: pelo menos 1 (default account)

# 2. Verificar índices
docker exec -i evo-postgres psql -U postgres -d evo_core -c "SELECT indexname FROM pg_indexes WHERE indexname LIKE '%account_id%';"
# Esperado: ~20 índices

# 3. Verificar constraints
docker exec -i evo-postgres psql -U postgres -d evo_core -c "SELECT conname FROM pg_constraint WHERE conname LIKE 'fk_%_account_id';"
# Esperado: 7 constraints

# 4. Verificar servidor
curl http://localhost:8080/health
# Esperado: 200 OK
```

---

## 🚨 Troubleshooting

### Erro: "violates foreign key constraint"

**Causa:** Existem registros com account_id inválido.

**Solução:**
```sql
-- Identificar
SELECT DISTINCT account_id FROM evo_core_agents 
WHERE account_id NOT IN (SELECT id FROM accounts);

-- Corrigir
UPDATE evo_core_agents 
SET account_id = '00000000-0000-0000-0000-000000000001'
WHERE account_id NOT IN (SELECT id FROM accounts);
```

### Erro: "column contains null values"

**Causa:** Ainda existem registros com account_id = NULL.

**Solução:**
```sql
-- Verificar
SELECT COUNT(*) FROM evo_core_agents WHERE account_id IS NULL;

-- Corrigir
UPDATE evo_core_agents 
SET account_id = '00000000-0000-0000-0000-000000000001' 
WHERE account_id IS NULL;
```

### Erro: 403 Forbidden em todas as requisições

**Causa:** Middleware de autorização muito restritivo ou token sem role.

**Solução:**
1. Verificar se o token contém `role` no payload
2. Verificar se o middleware está aplicado corretamente
3. Temporariamente usar `RequireViewer()` em todas as rotas para testar

### Performance Degradada

**Causa:** Índices não foram criados ou estatísticas desatualizadas.

**Solução:**
```sql
-- Recriar índices
REINDEX TABLE evo_core_agents;

-- Atualizar estatísticas
ANALYZE evo_core_agents;
```

---

## 📚 Documentação Completa

Para mais detalhes, consulte:

- **`MULTI_TENANT_IMPLEMENTATION_COMPLETE.md`** - Visão geral completa
- **`MIGRATION_000017_GUIDE.md`** - Guia detalhado de migração
- **`docs/admin-api-endpoints.md`** - Documentação da API
- **`FASES_3_4_5_COMPLETE.md`** - Detalhes das fases 3, 4, 5

---

## ⏱️ Tempo Estimado

- **Aplicar Migration:** 5 minutos
- **Registrar Rotas:** 2 minutos
- **Proteger Rotas:** 10 minutos
- **Rebuild Docker:** 5 minutos
- **Testes:** 5 minutos

**Total:** ~30 minutos

---

## ✅ Pronto!

Após seguir estes passos, seu sistema Evo CRM terá:

- ✅ Multi-tenancy completo
- ✅ Isolamento de dados
- ✅ Hierarquia de permissões
- ✅ Endpoints admin
- ✅ Testes automatizados

**Status:** 🟢 **PRONTO PARA PRODUÇÃO**

---

**Última Atualização:** 2026-04-29  
**Responsável:** Equipe de Desenvolvimento Evo CRM
