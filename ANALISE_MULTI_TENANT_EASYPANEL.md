# Análise Multi-Tenancy e Deploy no Easypanel - Evo CRM

## 📊 Status Atual do Multi-Tenancy

### ❌ **Multi-Tenancy NÃO Implementado no Core Service**

Após análise detalhada do código e migrações, o **EvoAI Core Service** atualmente **NÃO possui sistema de multi-tenancy implementado**.

#### Evidências:

1. **Estrutura de Tabelas Sem Isolamento**
   - Nenhuma tabela possui campo `user_id` ou `account_id`
   - Não há chaves estrangeiras para `accounts` do Evo CRM
   - Todas as tabelas são globais (compartilhadas entre todos os usuários)

2. **Tabelas Analisadas:**
   ```sql
   evo_core_agents          -- Sem user_id/account_id
   evo_core_custom_tools    -- Sem user_id/account_id
   evo_core_folders         -- Sem user_id/account_id
   evo_core_api_keys        -- Sem user_id/account_id
   evo_core_mcp_servers     -- Sem user_id/account_id
   ```

3. **Autenticação vs Multi-Tenancy**
   - ✅ Sistema de autenticação: **IMPLEMENTADO** (via EvoAuth)
   - ❌ Isolamento de dados por tenant: **NÃO IMPLEMENTADO**
   - ⚠️ Todos os usuários autenticados veem os mesmos dados

4. **Contexto de Autenticação**
   ```go
   // Dados disponíveis no contexto após autenticação:
   - user_id: UUID do usuário
   - email: Email do usuário
   - accounts: []EvoAuthAccount (lista de contas do usuário)
   
   // MAS: Não são usados para filtrar dados no banco
   ```

---

## 🔧 Implementação de Multi-Tenancy

### Estratégia Recomendada: **Account-Based Multi-Tenancy**

O sistema já possui integração com EvoAuth que retorna `accounts` do usuário. A implementação deve usar `account_id` como chave de isolamento.

### 1. Alterações no Banco de Dados

#### Adicionar `account_id` em todas as tabelas principais:

```sql
-- Migration: add_account_id_to_tables.up.sql

-- Agents
ALTER TABLE evo_core_agents 
ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;

CREATE INDEX idx_evo_core_agents_account_id ON evo_core_agents(account_id);

-- Custom Tools
ALTER TABLE evo_core_custom_tools 
ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;

CREATE INDEX idx_evo_core_custom_tools_account_id ON evo_core_custom_tools(account_id);

-- Folders
ALTER TABLE evo_core_folders 
ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;

CREATE INDEX idx_evo_core_folders_account_id ON evo_core_folders(account_id);

-- API Keys
ALTER TABLE evo_core_api_keys 
ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;

CREATE INDEX idx_evo_core_api_keys_account_id ON evo_core_api_keys(account_id);

-- MCP Servers (se for por tenant)
ALTER TABLE evo_core_custom_mcp_servers 
ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;

CREATE INDEX idx_evo_core_custom_mcp_servers_account_id ON evo_core_custom_mcp_servers(account_id);

-- Folder Shares
ALTER TABLE evo_core_folder_shares 
ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;

CREATE INDEX idx_evo_core_folder_shares_account_id ON evo_core_folder_shares(account_id);

-- Agent Integrations
ALTER TABLE evo_core_agent_integrations 
ADD COLUMN account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE;

CREATE INDEX idx_evo_core_agent_integrations_account_id ON evo_core_agent_integrations(account_id);
```

### 2. Middleware de Tenant Context

Criar middleware para extrair e validar `account_id`:

```go
// internal/middleware/tenant.go
package middleware

import (
    "context"
    "net/http"
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
)

func TenantMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        // Extrair accounts do contexto (injetado por EvoAuth)
        accounts, exists := c.Request.Context().Value("accounts").([]EvoAuthAccount)
        if !exists || len(accounts) == 0 {
            c.JSON(http.StatusForbidden, gin.H{"error": "No account associated"})
            c.Abort()
            return
        }

        // Usar primeira conta ativa (ou permitir seleção via header)
        accountID := accounts[0].ID
        
        // Permitir override via header X-Account-Id (opcional)
        if headerAccountID := c.GetHeader("X-Account-Id"); headerAccountID != "" {
            if parsedID, err := uuid.Parse(headerAccountID); err == nil {
                // Validar se usuário tem acesso a esta conta
                if hasAccess := validateAccountAccess(accounts, parsedID); hasAccess {
                    accountID = parsedID
                }
            }
        }

        // Injetar account_id no contexto
        ctx := context.WithValue(c.Request.Context(), "account_id", accountID)
        c.Request = c.Request.WithContext(ctx)
        
        c.Next()
    }
}

func validateAccountAccess(accounts []EvoAuthAccount, accountID uuid.UUID) bool {
    for _, acc := range accounts {
        if acc.ID == accountID && acc.Status == "active" {
            return true
        }
    }
    return false
}
```

### 3. Atualizar Repositories

Adicionar filtro `account_id` em todas as queries:

```go
// pkg/agent/repository/agent_repository.go

func (r *agentRepository) FindAll(ctx context.Context) ([]model.Agent, error) {
    accountID := ctx.Value("account_id").(uuid.UUID)
    
    var agents []model.Agent
    err := r.db.Where("account_id = ?", accountID).Find(&agents).Error
    return agents, err
}

func (r *agentRepository) Create(ctx context.Context, agent *model.Agent) error {
    accountID := ctx.Value("account_id").(uuid.UUID)
    agent.AccountID = accountID
    
    return r.db.Create(agent).Error
}

func (r *agentRepository) FindByID(ctx context.Context, id uuid.UUID) (*model.Agent, error) {
    accountID := ctx.Value("account_id").(uuid.UUID)
    
    var agent model.Agent
    err := r.db.Where("id = ? AND account_id = ?", id, accountID).First(&agent).Error
    return &agent, err
}
```

### 4. Atualizar Models

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

### 5. Registrar Middleware nas Rotas

```go
// cmd/api/main.go

v1 := router.Group("/api/v1")
v1.Use(evoAuthMiddleware.GetEvoAuthMiddleware())
v1.Use(middleware.TenantMiddleware()) // ADICIONAR AQUI
{
    customToolModule.Handler.RegisterRoutesMiddleware(v1)
    agentModule.Handler.RegisterRoutesMiddleware(v1)
    // ... outras rotas
}
```

---

## 🚀 Deploy no Easypanel

### ✅ **Compatibilidade: SIM, é possível**

O Easypanel suporta deploy via:
1. **Docker Compose** (método recomendado para este projeto)
2. **Templates JSON** (schema customizado)
3. **Dockerfile** (build individual)

### Arquivos de Deploy Disponíveis

O projeto já possui configuração completa para deploy:

1. **`docker-compose.dokploy.yaml`** ✅
   - Configuração completa de todos os serviços
   - Healthchecks implementados
   - Dependências corretas entre serviços
   - Volumes persistentes

2. **`_env.dokploy.example`** ✅
   - Todas as variáveis de ambiente necessárias
   - Segredos para serem alterados
   - Configurações de produção

### Arquitetura de Serviços

```
┌─────────────────────────────────────────────────────────────┐
│                      evo-gateway (3030)                      │
│                    API Gateway / Proxy                       │
└─────────────────────────────────────────────────────────────┘
                              ↓
        ┌─────────────────────┼─────────────────────┐
        ↓                     ↓                     ↓
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  evo-auth    │    │   evo-crm    │    │  evo-core    │
│   (3001)     │    │   (3000)     │    │   (5555)     │
└──────────────┘    └──────────────┘    └──────────────┘
        ↓                     ↓                     ↓
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ auth-sidekiq │    │ crm-sidekiq  │    │ evo-processor│
│              │    │              │    │   (8000)     │
└──────────────┘    └──────────────┘    └──────────────┘
                                                ↓
                                        ┌──────────────┐
                                        │ bot-runtime  │
                                        │   (8080)     │
                                        └──────────────┘
        ┌─────────────────────┼─────────────────────┐
        ↓                     ↓                     ↓
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  postgres    │    │    redis     │    │ evo-frontend │
│   (5432)     │    │   (6379)     │    │    (80)      │
└──────────────┘    └──────────────┘    └──────────────┘
```

### Serviços do Sistema

| Serviço | Imagem | Porta | Função |
|---------|--------|-------|--------|
| **postgres** | pgvector/pgvector:pg16 | 5432 | Banco de dados compartilhado |
| **redis** | redis:alpine | 6379 | Cache e filas |
| **evo-auth** | evoapicloud/evo-auth-service-community | 3001 | Autenticação e autorização |
| **evo-auth-sidekiq** | evoapicloud/evo-auth-service-community | - | Workers assíncronos (auth) |
| **evo-crm** | evoapicloud/evo-ai-crm-community | 3000 | CRM principal |
| **evo-crm-sidekiq** | evoapicloud/evo-ai-crm-community | - | Workers assíncronos (CRM) |
| **evo-core** | evoapicloud/evo-ai-core-service-community | 5555 | Core Service (IA) |
| **evo-processor** | evoapicloud/evo-ai-processor-community | 8000 | Processamento de IA |
| **evo-bot-runtime** | evoapicloud/evo-bot-runtime | 8080 | Runtime de bots |
| **evo-gateway** | evoapicloud/evo-crm-gateway | 3030 | Gateway/Proxy |
| **evo-frontend** | evoapicloud/evo-ai-frontend-community | 80 | Interface web |

### Jobs de Inicialização (One-Shot)

```yaml
evo_auth_init       # Prepara banco do Auth
evo_crm_init        # Prepara banco do CRM
evo_processor_init  # Prepara banco do Processor
```

---

## 📝 Passos para Deploy no Easypanel

### 1. Preparar Servidor

```bash
# Instalar Docker (se necessário)
curl -sSL https://get.docker.com | sh

# Instalar Easypanel
docker run --rm -it \
  -v /etc/easypanel:/etc/easypanel \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  easypanel/easypanel setup
```

### 2. Converter Docker Compose para Schema Easypanel

**Opção A: Usar ferramenta de conversão**
```bash
# Instalar conversor
npm install -g compose-to-easypanel

# Converter
compose-to-easypanel docker-compose.dokploy.yaml > easypanel-schema.json
```

**Opção B: Importar manualmente no Easypanel**
1. Acessar Easypanel UI
2. Criar novo projeto
3. Adicionar serviços manualmente baseado no docker-compose

### 3. Configurar Variáveis de Ambiente

Copiar `_env.dokploy.example` para `.env` e ajustar:

```bash
cp _env.dokploy.example .env
```

**Variáveis OBRIGATÓRIAS para alterar:**

```env
# Domínios públicos
BACKEND_URL=https://api.seudominio.com
FRONTEND_URL=https://app.seudominio.com
CORS_ORIGINS=https://app.seudominio.com,https://api.seudominio.com

# Segredos (gerar novos valores)
POSTGRES_PASSWORD=<gerar_senha_forte>
REDIS_PASSWORD=<gerar_senha_forte>
SECRET_KEY_BASE=<gerar_secret_64_chars>
JWT_SECRET_KEY=<gerar_secret_64_chars>
DOORKEEPER_JWT_SECRET_KEY=<gerar_secret_64_chars>
EVOAI_CRM_API_TOKEN=<gerar_token>
ENCRYPTION_KEY=<gerar_fernet_key>
BOT_RUNTIME_SECRET=<gerar_secret>
```

**Gerar secrets:**
```bash
# Gerar secrets aleatórios
openssl rand -base64 48

# Gerar Fernet key (para ENCRYPTION_KEY)
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

### 4. Ordem de Deploy

**Importante**: Seguir ordem de dependências:

```
1. postgres + redis (infraestrutura)
   ↓
2. evo_auth_init (preparar banco auth)
   ↓
3. evo-auth (serviço auth)
   ↓
4. evo_crm_init (preparar banco crm)
   ↓
5. evo-crm (serviço crm)
   ↓
6. evo-core (core service)
   ↓
7. evo_processor_init (preparar banco processor)
   ↓
8. evo-processor (processor)
   ↓
9. evo-bot-runtime (runtime)
   ↓
10. evo-gateway (gateway)
    ↓
11. evo-frontend (frontend)
    ↓
12. sidekiq workers (auth + crm)
```

### 5. Configurar Domínios no Easypanel

No Easypanel, configurar domínios para:

```
evo-gateway    → api.seudominio.com (porta 3030)
evo-frontend   → app.seudominio.com (porta 80)
```

### 6. Volumes Persistentes

Garantir volumes para dados persistentes:

```yaml
volumes:
  postgres_data:      # Dados do PostgreSQL
  redis_data:         # Dados do Redis
  processor_logs:     # Logs do processor
```

---

## ⚠️ Considerações Importantes

### Multi-Tenancy

1. **Estado Atual**: Sistema NÃO é multi-tenant
2. **Risco**: Todos os usuários veem os mesmos dados
3. **Recomendação**: Implementar multi-tenancy ANTES de produção
4. **Esforço**: Médio (2-3 dias de desenvolvimento)

### Segurança

1. **Alterar TODOS os secrets** antes do deploy
2. **Usar HTTPS** em produção (obrigatório)
3. **Configurar firewall** para portas internas
4. **Backup regular** do PostgreSQL

### Performance

1. **Recursos mínimos recomendados**:
   - CPU: 4 cores
   - RAM: 8GB
   - Disco: 50GB SSD

2. **Escalabilidade**:
   - Sidekiq workers podem ser escalados horizontalmente
   - PostgreSQL pode precisar de otimização para muitos tenants
   - Redis pode ser clusterizado se necessário

### Monitoramento

1. **Health checks** já implementados:
   ```
   /health       # Auth e CRM
   /ready        # Core
   /metrics      # Prometheus (se habilitado)
   ```

2. **Logs**: Todos os serviços logam para stdout (Docker logs)

---

## 🎯 Resumo Executivo

### Multi-Tenancy

| Aspecto | Status | Ação Necessária |
|---------|--------|-----------------|
| **Autenticação** | ✅ Implementado | Nenhuma |
| **Isolamento de Dados** | ❌ Não implementado | **CRÍTICO: Implementar antes de produção** |
| **Account Context** | ⚠️ Parcial | Adicionar middleware de tenant |
| **Queries Filtradas** | ❌ Não implementado | Atualizar todos os repositories |

### Deploy no Easypanel

| Aspecto | Status | Observação |
|---------|--------|------------|
| **Compatibilidade** | ✅ Sim | Docker Compose suportado |
| **Arquivos de Config** | ✅ Completos | docker-compose.dokploy.yaml pronto |
| **Variáveis de Ambiente** | ✅ Documentadas | _env.dokploy.example completo |
| **Healthchecks** | ✅ Implementados | Todos os serviços |
| **Volumes** | ✅ Configurados | Dados persistentes |
| **Ordem de Deploy** | ⚠️ Importante | Seguir dependências |

### Recomendações

1. **URGENTE**: Implementar multi-tenancy antes de produção
2. **Alterar**: Todos os secrets no arquivo .env
3. **Configurar**: Domínios públicos reais (HTTPS)
4. **Testar**: Deploy em ambiente de staging primeiro
5. **Monitorar**: Logs e health checks após deploy
6. **Backup**: Configurar backup automático do PostgreSQL

### Viabilidade

✅ **Deploy no Easypanel**: **VIÁVEL** - Arquivos prontos, apenas ajustar configurações

⚠️ **Multi-Tenancy**: **REQUER IMPLEMENTAÇÃO** - Sistema atual não isola dados por tenant

🔴 **Produção sem Multi-Tenancy**: **NÃO RECOMENDADO** - Risco de vazamento de dados entre usuários
