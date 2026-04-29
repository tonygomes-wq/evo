# Evo CRM Community — Índice de Documentação

> Gerado em: 2026-04-29 | Versão: v1.0.0-rc1 | Tipo: Monorepo (multi-serviço)

---

## Visão Geral do Projeto

| Campo | Valor |
|-------|-------|
| **Nome** | Evo CRM Community |
| **Tipo** | Monorepo com 6 serviços independentes |
| **Linguagens** | Go, Ruby (Rails), Python (FastAPI), TypeScript (React/Vite) |
| **Banco de Dados** | PostgreSQL 16 (pgvector) + Redis |
| **Licença** | Apache 2.0 |
| **Repositório** | EvolutionAPI/evo-crm-community |

---

## Arquitetura Resumida

```
evo-frontend (React/Vite - :5173)
    └── evo-gateway (API Gateway - :3030)
         ├── evo-auth  (Ruby/Rails - :3001)   → Autenticação, OAuth2, RBAC
         ├── evo-crm   (Ruby/Rails - :3000)   → CRM, conversas, contatos
         ├── evo-core  (Go/Gin    - :5555)    → Agentes IA, ferramentas, pastas
         └── evo-processor (Python/FastAPI - :8000)
              └── evo-bot-runtime (Go/Gin - :8080)
```

---

## Documentação Gerada

| Documento | Descrição |
|-----------|-----------|
| [Visão Geral do Projeto](./project-overview.md) | Propósito, arquitetura, serviços e dependências |
| [Arquitetura do Sistema](./architecture.md) | Design, padrões, fluxo de dados, DDD |
| [API Contracts — Core Service](./api-contracts-core.md) | Todos os endpoints do evo-core (Go) |
| [Modelos de Dados](./data-models.md) | Schema do banco de dados, tabelas, relacionamentos |
| [Guia de Desenvolvimento](./development-guide.md) | Setup local, comandos, ambiente |
| [Guia de Deploy](./deployment-guide.md) | Deploy com Docker Compose / Easypanel / Dokploy |
| [Arquitetura de Integração](./integration-architecture.md) | Como os serviços se comunicam entre si |
| [Análise de Multi-Tenancy](./multi-tenancy.md) | Status atual e roadmap de implementação |

---

## Documentação Existente (no repositório)

| Documento | Descrição |
|-----------|-----------|
| [ANALISE_SISTEMA.md](../ANALISE_SISTEMA.md) | Análise detalhada do EvoAI Core Service |
| [ANALISE_MULTI_TENANT_EASYPANEL.md](../ANALISE_MULTI_TENANT_EASYPANEL.md) | Multi-tenancy e deploy Easypanel |
| [README do Monorepo](../evo-crm-community-main/README.md) | README oficial do projeto |
| [.env.dokploy.example](../_env.dokploy.example) | Template de variáveis para produção |

---

## Quick Reference

### Serviços e Portas

| Serviço | Stack | Porta | Função |
|---------|-------|-------|--------|
| `evo-gateway` | Nginx/Proxy | 3030 | API Gateway unificado |
| `evo-auth` | Ruby 3.4 / Rails 7.1 | 3001 | Autenticação, RBAC, OAuth2 |
| `evo-crm` | Ruby 3.4 / Rails 7.1 | 3000 | CRM, conversas, contatos |
| `evo-core` | Go / Gin | 5555 | Gerenciamento de agentes IA |
| `evo-processor` | Python 3.10 / FastAPI | 8000 | Execução de agentes IA |
| `evo-bot-runtime` | Go / Gin | 8080 | Pipeline de bots |
| `evo-frontend` | React / TypeScript / Vite | 5173 | Interface web |
| `postgres` | PostgreSQL 16 + pgvector | 5432 | Banco de dados compartilhado |
| `redis` | Redis Alpine | 6379 | Cache e filas |

### Health Checks

```
GET http://localhost:3001/health    → evo-auth
GET http://localhost:3000/health/live → evo-crm
GET http://localhost:5555/health    → evo-core
GET http://localhost:5555/ready     → evo-core
GET http://localhost:5555/metrics   → evo-core (Prometheus)
```

---

## Getting Started

```bash
# 1. Clonar com submodules
git clone --recurse-submodules git@github.com:EvolutionAPI/evo-crm-community.git
cd evo-crm-community

# 2. Configurar variáveis de ambiente
cp _env.dokploy.example .env
# Editar .env com seus valores

# 3. Subir todos os serviços
docker-compose -f docker-compose.dokploy.yaml up -d
```

Consulte o [Guia de Deploy](./deployment-guide.md) para instruções detalhadas.
