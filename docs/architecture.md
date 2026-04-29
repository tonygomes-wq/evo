# Evo CRM — Arquitetura do Sistema

## Visão Arquitetural

O Evo CRM adota uma **arquitetura de microserviços** com comunicação via HTTP/REST e autenticação Bearer Token unificada. Cada serviço tem responsabilidade única e pode ser escalado independentemente.

---

## Padrão Arquitetural por Serviço

### evo-core (Go/Gin) — Domain-Driven Design

O serviço mais estruturado do ecossistema, segue DDD estrito:

```
evo-ai-core-service-community/
├── cmd/api/
│   └── main.go                   # Entry point: init, DI, rotas
├── internal/                     # Código privado (não exportável)
│   ├── config/                   # Configuração via variáveis de ambiente
│   ├── middleware/               # HTTP middlewares
│   │   ├── evo_auth.go           # ★ Autenticação principal (Bearer Token)
│   │   ├── permission.go         # Controle de acesso por permissão
│   │   ├── cors.go               # CORS configurável
│   │   ├── rate_limiter.go       # Rate limiting global e por cliente
│   │   └── jwt.go                # ⚠️ Legado (não utilizado)
│   ├── services/
│   │   └── evo_auth_service.go   # Cliente do EvoAuth Service
│   ├── security/                 # Utilitários de segurança (hashing)
│   ├── telemetry/                # OpenTelemetry (opcional)
│   ├── types/                    # Tipos compartilhados entre módulos
│   ├── utils/                    # context, JWT, string, HTTP helpers
│   ├── httpclient/               # Cliente HTTP reutilizável
│   └── infra/postgres/           # Conexão GORM + pool
├── pkg/                          # Módulos de domínio
│   ├── agent/                    # Agentes IA
│   ├── agent_integration/        # Integrações externas de agentes
│   ├── api_key/                  # Chaves API (criptografadas)
│   ├── custom_tool/              # Ferramentas HTTP customizadas
│   ├── custom_mcp_server/        # Servidores MCP customizados
│   ├── mcp_server/               # Registro de servidores MCP globais
│   ├── folder/                   # Organização de workspace
│   ├── folder_share/             # Compartilhamento e permissões
│   └── core/                     # Health checks e métricas
└── migrations/                   # Migrações SQL (golang-migrate)
```

#### Padrão de módulo (pkg/)

Cada módulo de domínio segue o mesmo layout:

```
pkg/{modulo}/
├── handler/      # Controllers: validação de input, rotas HTTP, formatação de response
├── service/      # Lógica de negócio e regras de domínio
├── repository/   # Acesso a dados via GORM
├── model/        # Structs de dados, DTOs, validações
└── module.go     # Wire: injeção de dependências do módulo
```

**Fluxo de uma requisição:**
```
HTTP Request
  → Middleware (Auth → Tenant → Permission)
  → Handler (validação, parsing)
  → Service (regra de negócio)
  → Repository (query GORM)
  → PostgreSQL
  → Repository (resultado)
  → Service (transformação)
  → Handler (response JSON)
  → HTTP Response
```

---

### evo-auth / evo-crm (Ruby/Rails) — MVC + Sidekiq

Ambos os serviços Ruby seguem a arquitetura padrão Rails:

```
app/
├── controllers/    # HTTP handlers (Rails controllers)
├── models/         # ActiveRecord models + validações
├── services/       # Service objects para lógica complexa
├── workers/        # Sidekiq jobs assíncronos
├── serializers/    # Formatação de responses JSON
└── policies/       # Autorização (Pundit/CanCan)

db/
├── schema.rb       # Schema atual do banco
└── migrate/        # Migrações Rails
```

**Workers assíncronos (Sidekiq):**
- `evo-auth-sidekiq` → processamento assíncrono de autenticação
- `evo-crm-sidekiq` → webhooks, notificações, processamento de mensagens

### evo-processor (Python/FastAPI) — Hexagonal-ish

```
app/
├── api/           # Rotas FastAPI (controllers)
├── core/          # Configuração, dependências
├── models/        # Modelos SQLAlchemy / Pydantic
├── services/      # Lógica de execução de agentes
├── repositories/  # Acesso a dados (async)
└── adapters/      # Integrações externas (MCP, LLMs)

alembic/           # Migrações de banco
scripts/           # Seeders e scripts de setup
```

---

## Middleware Stack (evo-core)

Ordem de execução para rotas protegidas:

```
1. CORS Middleware
   → valida Origin header
   → adiciona headers de resposta CORS

2. Rate Limiter (Global)
   → limite: RATE_LIMIT_GLOBAL_RPS requisições/s
   → burst: RATE_LIMIT_GLOBAL_BURST

3. Rate Limiter (Por Cliente/IP)
   → limite: RATE_LIMIT_CLIENT_RPS req/s por IP
   → burst: RATE_LIMIT_CLIENT_BURST

4. EvoAuth Middleware
   → extrai Bearer Token do header Authorization
   → fallback: api_access_token / HTTP_API_ACCESS_TOKEN
   → valida com POST /api/v1/auth/validate no evo-auth
   → injeta no contexto: user_id, email, name, role, accounts

5. [Futuro] Tenant Middleware
   → extrai account_id da lista de accounts
   → suporte a X-Account-Id header
   → injeta account_id no contexto

6. Permission Middleware (rotas específicas)
   → RequirePermission(resource, action)
   → verifica com EvoAuth CheckPermission
   → fallback: permite acesso se endpoint não existe (404)

7. Route Handler
   → processa a requisição
```

---

## Segurança

### Criptografia de API Keys
- Algoritmo: **Fernet** (symmetric encryption)
- Chave compartilhada com `evo-processor` via `ENCRYPTION_KEY`
- Formato: 32 bytes URL-safe base64

### JWT
- Algoritmo: `HS256`
- Secret: `JWT_SECRET_KEY` (compartilhado entre serviços)
- Emissão: exclusivamente pelo `evo-auth`
- Validação: cada serviço valida via `evo-auth`

### CORS
- Origem configurável via `EVOLUTION_BASE_URL` / `CORS_ORIGINS`
- Headers expostos: `Authorization`, `X-Account-Id`, `X-User-Id`

### Rate Limiting (evo-core)
```
RATE_LIMIT_GLOBAL_RPS=1000    # Global: requisições/segundo
RATE_LIMIT_GLOBAL_BURST=50    # Global: burst
RATE_LIMIT_CLIENT_RPS=100     # Por cliente: req/s
RATE_LIMIT_CLIENT_BURST=10    # Por cliente: burst
```

---

## Observabilidade

### evo-core
- **OpenTelemetry**: traces distribuídos (opcional, `OTEL_TRACES_ENABLED=true`)
- **Prometheus**: métricas em `/metrics` (se habilitado)
- **Health checks**: `/health` e `/ready`

### evo-auth / evo-crm
- **Health checks**: `/health` e `/health/live`
- Logs para stdout (capturados pelo Docker)

---

## Escalabilidade

| Componente | Estratégia |
|------------|------------|
| `evo-auth-sidekiq` | Escalar workers horizontalmente |
| `evo-crm-sidekiq` | Escalar workers horizontalmente |
| `evo-processor` | Stateless → múltiplas réplicas |
| `postgres` | Connection pool (10 min / 100 max) |
| `redis` | Clusterizável se necessário |
