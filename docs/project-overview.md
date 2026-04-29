# Evo CRM Community — Visão Geral do Projeto

## O que é o Evo CRM?

O **Evo CRM Community** é uma plataforma open-source de suporte ao cliente com IA integrada, desenvolvida pela [Evolution Foundation](https://evolutionfoundation.com.br). É a edição community do Evo CRM, focada em ser:

- **Single-tenant** (Community Edition) — uma conta, sem sobrecarga de multi-tenancy
- **Auto-hospedável** — Docker Compose / Easypanel / Dokploy
- **IA-first** — agentes de IA integrados nativamente ao fluxo de atendimento
- **Open-source** — licença Apache 2.0

## Versão Atual

**v1.0.0-rc1** — primeiro release candidate. O repositório é um monorepo que agrega 6 serviços independentes como submódulos Git.

---

## Componentes do Sistema

### 1. evo-auth-service-community
- **Stack**: Ruby 3.4 / Rails 7.1
- **Porta**: 3001
- **Função**: Autenticação central, RBAC, OAuth2, emissão de tokens JWT
- **Dependências**: PostgreSQL, Redis
- **Papéis suportados**: `account_owner`, `agent`

### 2. evo-ai-crm-community
- **Stack**: Ruby 3.4 / Rails 7.1
- **Porta**: 3000
- **Função**: CRM principal — conversas, contatos, inboxes, mensagens
- **Dependências**: PostgreSQL, Redis, evo-auth, evo-core, evo-bot-runtime

### 3. evo-ai-core-service-community
- **Stack**: Go 1.24.4 / Gin
- **Porta**: 5555
- **Função**: Gerenciamento de agentes IA, ferramentas customizadas, chaves API, pastas, servidores MCP
- **Padrão arquitetural**: Domain-Driven Design (DDD)
- **Dependências**: PostgreSQL, evo-auth

### 4. evo-ai-processor-community
- **Stack**: Python 3.10 / FastAPI
- **Porta**: 8000
- **Função**: Execução de agentes IA, sessões, ferramentas, integração MCP
- **Dependências**: PostgreSQL, Redis, evo-crm, evo-core, evo-bot-runtime

### 5. evo-bot-runtime
- **Stack**: Go / Gin
- **Porta**: 8080
- **Função**: Execução de pipeline de bots, debouncing, despacho
- **Dependências**: Redis, evo-processor

### 6. evo-ai-frontend-community
- **Stack**: React / TypeScript / Vite
- **Porta**: 5173 (produção: 80)
- **Função**: Interface web do usuário
- **Dependências**: evo-gateway (proxy para todos os serviços)

---

## Infraestrutura de Suporte

| Serviço | Imagem | Porta | Função |
|---------|--------|-------|--------|
| **postgres** | pgvector/pgvector:pg16 | 5432 | Banco compartilhado (com suporte a vetores para IA) |
| **redis** | redis:alpine | 6379 | Cache, filas Sidekiq, sessões |
| **evo-gateway** | evoapicloud/evo-crm-gateway | 3030 | API Gateway / Reverse proxy unificado |

---

## Diagrama de Dependências

```
evo-frontend
    └── evo-gateway (3030)
         ├── evo-auth (3001)
         │    └── [auth-sidekiq] workers assíncronos
         │    └── PostgreSQL (DB: evo_community, schema: auth)
         │    └── Redis (DB: 1)
         │
         ├── evo-crm (3000)
         │    └── [crm-sidekiq] workers assíncronos
         │    └── PostgreSQL (DB: evo_community, schema: crm)
         │    └── Redis (DB: 0)
         │    └── → evo-auth (validação de tokens)
         │    └── → evo-core (agentes e ferramentas)
         │    └── → evo-bot-runtime (despacho de bots)
         │
         ├── evo-core (5555)
         │    └── PostgreSQL (tabelas prefixadas: evo_core_*)
         │    └── → evo-auth (validação de tokens)
         │
         └── evo-processor (8000)
              └── PostgreSQL
              └── Redis
              └── → evo-crm (dados de conversas)
              └── → evo-core (definições de agentes)
              └── → evo-bot-runtime (execução)
                   └── Redis
                   └── → evo-processor
```

---

## Fluxo de Autenticação

Todo o sistema usa **Bearer Token** emitido pelo `evo-auth`. O token é propagado entre serviços sem necessidade de headers adicionais.

```
Cliente
  → Bearer Token
  → evo-gateway
  → Serviço destino
  → Valida token com evo-auth (POST /api/v1/auth/validate)
  → Contexto enriquecido com dados do usuário e contas
  → Requisição processada
```

---

## Banco de Dados Compartilhado

Todos os serviços compartilham o **mesmo servidor PostgreSQL** (database: `evo_community`), mas usam schemas/prefixos de tabela separados para evitar conflitos:

| Serviço | Prefixo / Schema | Tabela de migrações |
|---------|------------------|---------------------|
| evo-auth | schema `public` (Rails) | `schema_migrations` |
| evo-crm | schema `public` (Rails) | `schema_migrations` |
| evo-core | prefixo `evo_core_` | `evo_core_schema_community_migrations` |
| evo-processor | prefixo definido pelo Alembic | `alembic_version` |

> **Nota importante**: O `evo-core` referencia a tabela `accounts(id)` do `evo-crm` para futuras chaves estrangeiras de multi-tenancy.

---

## Princípios de Design (Community Edition)

- ✅ **Single-tenant** — uma organização, sem hierarquia de tenants
- ✅ **Sem super-admin** — toda configuração via seed e variáveis de ambiente
- ✅ **Sem billing/planos** — todos os limites removidos, features desbloqueadas
- ✅ **Papéis simples**: `account_owner` e `agent`
- ✅ **Account resolution via token** — sem header `account-id` entre serviços
- ⚠️ **Multi-tenancy não implementado** no Core Service (ver [análise](./multi-tenancy.md))
