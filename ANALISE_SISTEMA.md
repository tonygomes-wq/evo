# Análise Completa do Sistema EvoAI Core Service

## 📋 Visão Geral do Sistema

O **EvoAI Core Service** é um microserviço de IA desenvolvido em **Go 1.24.4** que fornece funcionalidades avançadas de inteligência artificial integradas ao **Evo CRM**. O sistema segue uma arquitetura **Domain-Driven Design (DDD)** com separação clara entre camadas.

### Tecnologias Principais
- **Linguagem**: Go 1.24.4
- **Framework Web**: Gin (HTTP router)
- **Banco de Dados**: PostgreSQL 12+ (compartilhado com Evo CRM)
- **ORM**: GORM
- **Autenticação**: Bearer Token via EvoAuth Service
- **Observabilidade**: OpenTelemetry (opcional)
- **Containerização**: Docker + Docker Compose

---

## 🔐 Sistema de Autenticação

### 1. Arquitetura de Autenticação

O sistema utiliza **autenticação delegada** ao serviço **EvoAuth**, não gerenciando credenciais localmente.

#### Fluxo de Autenticação:
```
Cliente → Bearer Token → EvoAI Core Service → Valida com EvoAuth → Contexto da Requisição
```

### 2. Arquivos de Autenticação

#### **Middleware Principal** (`internal/middleware/evo_auth.go`)
- **Função**: Intercepta todas as requisições protegidas
- **Validação**: Extrai token Bearer e valida via EvoAuth API
- **Contexto**: Injeta informações do usuário no contexto da requisição
- **Suporte**: Bearer Token (prioritário) e api_access_token (fallback)

**Dados injetados no contexto:**
```go
- user_id: UUID do usuário
- email: Email do usuário
- name: Nome do usuário
- token: Token original
- token_type: "bearer" ou "api_access_token"
- user: Objeto completo do usuário
- role: Papel do usuário
- type: Tipo de usuário
- api_access_token: Token para chamadas Evo CRM
```

#### **Serviço de Autenticação** (`internal/services/evo_auth_service.go`)
- **Função**: Comunicação com EvoAuth API
- **Métodos principais**:
  - `ValidateToken()`: Valida token com EvoAuth
  - `CheckPermission()`: Verifica permissões do usuário
  - `CheckAccountPermission()`: Verifica permissões por conta
  - `CheckUserPermission()`: Verifica permissões globais

**Endpoint de validação:**
```
POST /api/v1/auth/validate
Headers: Authorization: Bearer {token}
```

#### **Middleware de Permissões** (`internal/middleware/permission.go`)
- **Função**: Controle de acesso baseado em permissões
- **Uso**: `RequirePermission(resource, action)`
- **Exemplo**: `RequirePermission("agents", "create")`
- **Fallback**: Se endpoint de permissões não existe (404), permite acesso para usuários autenticados

#### **Middleware JWT Legado** (`internal/middleware/jwt.go`)
- **Status**: Não utilizado atualmente
- **Função**: Validação JWT local (substituído por EvoAuth)
- **Pode ser removido**: Sim, se não houver planos de uso futuro

### 3. Configuração de Autenticação

**Variáveis de ambiente necessárias** (`.env`):
```env
# EvoAuth Service
EVO_AUTH_BASE_URL=http://localhost:3001

# JWT (para compatibilidade com Evo CRM)
JWT_SECRET_KEY=<mesmo_secret_do_evo_crm>
JWT_ALGORITHM=HS256

# Evo CRM Integration
EVOLUTION_BASE_URL=http://localhost:3000
```

### 4. Headers HTTP Suportados

**Autenticação:**
```http
Authorization: Bearer {access_token}
```

**Alternativo (fallback):**
```http
api_access_token: {token}
HTTP_API_ACCESS_TOKEN: {token}
```

### 5. Resposta de Validação do EvoAuth

```json
{
  "user": {
    "id": "uuid",
    "name": "Nome do Usuário",
    "email": "email@example.com",
    "role": "admin",
    "type": "user"
  },
  "accounts": [
    {
      "id": "uuid",
      "name": "Account Name",
      "status": "active"
    }
  ]
}
```

---

## 🏗️ Arquitetura do Sistema

### 1. Estrutura de Diretórios

```
evo-ai-core-service-community-main/
├── cmd/api/                    # Ponto de entrada da aplicação
│   └── main.go                 # Inicialização e configuração de rotas
├── internal/                   # Código privado (não exportável)
│   ├── config/                 # Gerenciamento de configuração
│   ├── middleware/             # Middlewares HTTP (auth, CORS, rate limit)
│   ├── services/               # Serviços compartilhados (EvoAuth)
│   ├── security/               # Utilitários de segurança (password hashing)
│   ├── telemetry/              # OpenTelemetry setup
│   ├── types/                  # Tipos compartilhados
│   ├── utils/                  # Utilitários (context, JWT, string, HTTP)
│   ├── httpclient/             # Cliente HTTP reutilizável
│   └── infra/postgres/         # Conexão com banco de dados
├── pkg/                        # Módulos de domínio (públicos)
│   ├── agent/                  # Gerenciamento de agentes IA
│   ├── agent_integration/      # Integrações de agentes
│   ├── api_key/                # Gerenciamento de chaves API
│   ├── custom_tool/            # Ferramentas HTTP customizadas
│   ├── custom_mcp_server/      # Servidores MCP customizados
│   ├── mcp_server/             # Registro de servidores MCP
│   ├── folder/                 # Organização de workspace
│   ├── folder_share/           # Compartilhamento de pastas
│   └── core/                   # Health checks e sistema
├── migrations/                 # Migrações de banco de dados
├── .github/                    # GitHub Actions (CI/CD)
├── Dockerfile                  # Containerização
├── docker-compose.yml          # Orquestração local
├── Makefile                    # Comandos de desenvolvimento
└── README.md                   # Documentação principal
```

### 2. Padrão de Módulos (Domain-Driven Design)

Cada módulo em `pkg/` segue a estrutura:

```
pkg/{modulo}/
├── handler/        # Controllers HTTP (rotas, validação, resposta)
├── service/        # Lógica de negócio
├── repository/     # Acesso a dados (GORM)
├── model/          # Estruturas de dados e DTOs
└── module.go       # Injeção de dependências
```

**Exemplo de fluxo:**
```
HTTP Request → Handler → Service → Repository → Database
                  ↓
            Validação e Response
```

### 3. Módulos Principais

| Módulo | Descrição | Tabela DB |
|--------|-----------|-----------|
| **agent** | Gerenciamento de agentes IA com tipos variados | `evo_core_agents` |
| **api_key** | Armazenamento criptografado de credenciais | `evo_core_api_keys` |
| **custom_tool** | Ferramentas HTTP personalizadas para agentes | `evo_core_custom_tools` |
| **custom_mcp_server** | Servidores MCP customizados | `evo_core_custom_mcp_servers` |
| **mcp_server** | Registro de servidores Model Context Protocol | `evo_core_mcp_servers` |
| **folder** | Organização de workspace | `evo_core_folders` |
| **folder_share** | Compartilhamento e permissões de pastas | `evo_core_folder_shares` |
| **agent_integration** | Integrações externas de agentes | `evo_core_agent_integrations` |
| **core** | Health checks e métricas do sistema | - |

---

## 🗄️ Banco de Dados

### 1. Estratégia de Banco

- **Banco Compartilhado**: Utiliza o mesmo PostgreSQL do Evo CRM
- **Prefixo de Tabelas**: `evo_core_` para evitar conflitos
- **Tabela de Migrações**: `evo_core_schema_community_migrations` (customizada)
- **Chaves Estrangeiras**: Referencia `accounts(id)` do Evo CRM para multi-tenancy

### 2. Migrações

**Localização**: `migrations/`

**Tabela de migrações customizada** para não conflitar com Rails:
```sql
evo_core_schema_community_migrations
```

**Comandos principais:**
```bash
make migrate-up              # Aplicar migrações pendentes
make migrate-down            # Reverter última migração
make migrate-create NAME=x   # Criar nova migração
make db-reset                # Resetar banco completo
```

### 3. Configuração de Conexão

**Variáveis de ambiente:**
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=root
DB_NAME=evo_community
DB_SSLMODE=disable

# Pool de conexões
DB_MAX_IDLE_CONNS=10
DB_MAX_OPEN_CONNS=100
DB_CONN_MAX_LIFETIME=1h
DB_CONN_MAX_IDLE_TIME=30m
```

---

## 🚀 Endpoints da API

### Rotas Públicas (sem autenticação)
```
GET  /health        # Health check
GET  /ready         # Readiness check
GET  /metrics       # Métricas Prometheus (se habilitado)
```

### Rotas Protegidas (requerem Bearer Token)

**Base URL**: `/api/v1`

#### Agents
```
GET    /api/v1/agents           # Listar agentes
POST   /api/v1/agents           # Criar agente
GET    /api/v1/agents/:id       # Obter agente
PUT    /api/v1/agents/:id       # Atualizar agente
DELETE /api/v1/agents/:id       # Deletar agente
```

#### Custom Tools
```
GET    /api/v1/custom-tools         # Listar ferramentas
POST   /api/v1/custom-tools         # Criar ferramenta
GET    /api/v1/custom-tools/:id     # Obter ferramenta
PUT    /api/v1/custom-tools/:id     # Atualizar ferramenta
DELETE /api/v1/custom-tools/:id     # Deletar ferramenta
GET    /api/v1/custom-tools/:id/test # Testar ferramenta
```

#### API Keys
```
GET    /api/v1/apikeys          # Listar chaves
POST   /api/v1/apikeys          # Criar chave
PUT    /api/v1/apikeys/:id      # Atualizar chave
DELETE /api/v1/apikeys/:id      # Deletar chave
```

#### Folders
```
GET    /api/v1/folders                      # Listar pastas
GET    /api/v1/folders/accessible-folders   # Pastas acessíveis
POST   /api/v1/folders                      # Criar pasta
PUT    /api/v1/folders/:id                  # Atualizar pasta
DELETE /api/v1/folders/:id                  # Deletar pasta
```

#### MCP Servers
```
GET    /api/v1/mcp-servers      # Listar servidores MCP
POST   /api/v1/mcp-servers      # Criar servidor MCP
GET    /api/v1/mcp-servers/:id  # Obter servidor MCP
PUT    /api/v1/mcp-servers/:id  # Atualizar servidor MCP
DELETE /api/v1/mcp-servers/:id  # Deletar servidor MCP
```

---

## 🛡️ Segurança

### 1. Criptografia
- **API Keys**: Criptografadas com Fernet (chave compartilhada com evo-ai-processor)
- **Variável**: `ENCRYPTION_KEY` (32 bytes URL-safe base64)

### 2. Rate Limiting
```env
RATE_LIMIT_GLOBAL_RPS=1000      # Requisições globais por segundo
RATE_LIMIT_GLOBAL_BURST=50      # Burst global
RATE_LIMIT_CLIENT_RPS=100       # Requisições por cliente/segundo
RATE_LIMIT_CLIENT_BURST=10      # Burst por cliente
```

### 3. CORS
- **Configuração**: `internal/middleware/cors.go`
- **Origem permitida**: Configurável via `EVOLUTION_BASE_URL`
- **Headers expostos**: Authorization, X-Account-Id, X-User-Id

---

## 📁 Pastas Desnecessárias para Rodar o Projeto

### ❌ Podem ser Removidas (Não Essenciais)

1. **`.github/`**
   - **Conteúdo**: GitHub Actions, workflows CI/CD
   - **Impacto**: Nenhum na execução local
   - **Quando manter**: Se usar GitHub Actions para deploy

2. **`docs/` (se existir)**
   - **Conteúdo**: Documentação adicional
   - **Impacto**: Nenhum na execução
   - **Nota**: Não encontrada na estrutura atual

3. **`.git/`**
   - **Conteúdo**: Histórico Git
   - **Impacto**: Nenhum na execução
   - **Quando manter**: Para controle de versão

### ⚠️ Podem ser Simplificadas

1. **`internal/middleware/jwt.go`**
   - **Status**: Não utilizado (substituído por EvoAuth)
   - **Ação**: Pode ser removido se não houver planos de uso

2. **`internal/telemetry/`**
   - **Função**: OpenTelemetry (observabilidade)
   - **Impacto**: Opcional, pode ser desabilitado
   - **Variável**: `OTEL_TRACES_ENABLED=false`

### ✅ Essenciais (NÃO Remover)

- `cmd/` - Ponto de entrada
- `internal/` - Lógica interna (config, middleware, services, utils)
- `pkg/` - Módulos de domínio
- `migrations/` - Migrações de banco
- `go.mod`, `go.sum` - Dependências
- `Dockerfile`, `docker-compose.yml` - Containerização
- `Makefile` - Comandos de desenvolvimento
- `.env.example` - Template de configuração

---

## 🔧 Comandos de Desenvolvimento

### Setup Inicial
```bash
make setup          # Instala dependências + configura banco
make install        # Apenas instala dependências
```

### Desenvolvimento
```bash
make dev            # Modo desenvolvimento (hot reload)
make run            # Modo produção
make build          # Compilar binário
```

### Banco de Dados
```bash
make db-setup       # Criar banco + migrações
make db-reset       # Resetar banco completo
make migrate-up     # Aplicar migrações
make migrate-down   # Reverter migração
```

### Docker
```bash
docker-compose up -d        # Subir serviço
docker-compose logs -f      # Ver logs
docker-compose down         # Parar serviço
```

---

## 🔗 Dependências Externas

### Serviços Requeridos

1. **PostgreSQL 12+**
   - Banco de dados compartilhado com Evo CRM
   - Porta padrão: 5432

2. **EvoAuth Service**
   - Serviço de autenticação
   - URL: `EVO_AUTH_BASE_URL` (ex: http://localhost:3001)
   - **Crítico**: Sistema não funciona sem EvoAuth

3. **Evo CRM API** (opcional)
   - Para criação de bots e integrações
   - URL: `EVOLUTION_BASE_URL` (ex: http://localhost:3000)

4. **AI Processor Service**
   - Processamento de IA
   - URL: `AI_PROCESSOR_URL` (ex: http://localhost:8080)

### Bibliotecas Go Principais

```go
github.com/gin-gonic/gin              // Framework web
gorm.io/gorm                          // ORM
github.com/golang-jwt/jwt/v5          // JWT
github.com/fernet/fernet-go           // Criptografia
go.opentelemetry.io/otel              // Observabilidade
github.com/prometheus/client_golang   // Métricas
golang.org/x/time                     // Rate limiting
```

---

## 📊 Fluxo de Requisição Completo

```
1. Cliente envia requisição com Bearer Token
   ↓
2. Middleware CORS valida origem
   ↓
3. Middleware Rate Limit verifica limites
   ↓
4. Middleware EvoAuth extrai e valida token
   ↓
5. EvoAuth Service valida com API externa
   ↓
6. Contexto é enriquecido com dados do usuário
   ↓
7. Middleware Permission (se aplicável) verifica permissões
   ↓
8. Handler processa requisição
   ↓
9. Service executa lógica de negócio
   ↓
10. Repository acessa banco de dados
    ↓
11. Resposta é formatada e retornada
```

---

## 🎯 Resumo Executivo

### O que o sistema faz?
Microserviço de IA que gerencia agentes, ferramentas customizadas, chaves API e integrações MCP para o ecossistema **Evo CRM**.

### Como funciona a autenticação?
Autenticação delegada via Bearer Token validado pelo serviço EvoAuth. Não há gerenciamento local de credenciais.

### Arquivos críticos de autenticação:
1. `internal/middleware/evo_auth.go` - Middleware principal
2. `internal/services/evo_auth_service.go` - Cliente EvoAuth
3. `internal/middleware/permission.go` - Controle de permissões
4. `internal/config/config.go` - Configurações

### O que pode ser removido?
- `.github/` (se não usar CI/CD)
- `internal/middleware/jwt.go` (não utilizado)
- `internal/telemetry/` (se não usar observabilidade)

### Dependências essenciais:
- PostgreSQL (banco compartilhado com Evo CRM)
- EvoAuth Service (autenticação)
- AI Processor Service (processamento IA)
- Evo CRM API (opcional, para bots e integrações)
