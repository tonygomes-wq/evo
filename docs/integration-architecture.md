# Evo CRM — Arquitetura de Integração Entre Serviços

## Visão Geral

Todos os serviços comunicam via **HTTP/REST** usando **Bearer Token** emitido pelo `evo-auth`. Não há mensageria assíncrona entre serviços (apenas Redis para filas Sidekiq internas ao auth e crm).

---

## Mapa de Integrações

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENTE EXTERNO                             │
└────────────────────────────┬────────────────────────────────────────┘
                             │ HTTPS + Bearer Token
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    evo-gateway (:3030)                              │
│                    Reverse Proxy / API Gateway                      │
└──────┬──────────────────┬──────────────────┬───────────────────────┘
       │                  │                  │
       ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐
│  evo-auth    │  │  evo-crm     │  │      evo-core        │
│   (:3001)    │  │   (:3000)    │  │       (:5555)        │
│  Ruby/Rails  │  │  Ruby/Rails  │  │       Go/Gin         │
│              │  │              │  │                      │
│ • Auth       │  │ • Conversas  │  │ • Agentes            │
│ • RBAC       │  │ • Contatos   │  │ • Ferramentas        │
│ • OAuth2     │  │ • Inboxes    │  │ • API Keys           │
│ • JWT        │  │ • Mensagens  │  │ • Pastas             │
└──────┬───────┘  └──────┬───────┘  └──────────────────────┘
       │                  │                  ▲
       │ valida tokens     │                  │
       ◄──────────────────┤                  │
       │                  │                  │
       ◄──────────────────┼──────────────────┘
       │  todos os serviços│validam token com evo-auth
       │                  │
       │                  ▼
       │         ┌──────────────────────┐
       │         │    evo-processor     │
       │         │       (:8000)        │
       │         │    Python/FastAPI    │
       │         │                     │
       │         │ • Execução de IA    │
       │         │ • Sessões           │
       │         │ • MCP integration   │
       │         └──────────┬──────────┘
       │                    │
       │                    ▼
       │         ┌──────────────────────┐
       │         │   evo-bot-runtime   │
       │         │       (:8080)        │
       │         │       Go/Gin         │
       │         │                     │
       │         │ • Pipeline de bots  │
       │         │ • Debouncing        │
       └─────────┘ • Despacho          │
                  └──────────────────────┘
```

---

## Tabela de Integrações

| De | Para | Protocolo | Propósito |
|----|------|-----------|-----------|
| `evo-frontend` | `evo-gateway` | HTTPS/REST | Todas as chamadas de API |
| `evo-gateway` | `evo-auth` | HTTP/REST | Roteamento de autenticação |
| `evo-gateway` | `evo-crm` | HTTP/REST | Roteamento de CRM |
| `evo-gateway` | `evo-core` | HTTP/REST | Roteamento de agentes/ferramentas |
| `evo-gateway` | `evo-processor` | HTTP/REST | Roteamento de execução IA |
| `evo-crm` | `evo-auth` | HTTP/REST | Validação de tokens |
| `evo-crm` | `evo-core` | HTTP/REST | Busca de agentes e ferramentas |
| `evo-crm` | `evo-bot-runtime` | HTTP/REST | Despacho de bots |
| `evo-core` | `evo-auth` | HTTP/REST | Validação de tokens |
| `evo-processor` | `evo-crm` | HTTP/REST | Dados de conversas |
| `evo-processor` | `evo-core` | HTTP/REST | Definições de agentes e ferramentas |
| `evo-processor` | `evo-bot-runtime` | HTTP/REST | Execução de pipeline |
| `evo-bot-runtime` | `evo-processor` | HTTP/REST | Callbacks de execução |
| `evo-bot-runtime` | `evo-crm` | HTTP/REST | Postback de resultados |
| `*-sidekiq` | `redis` | Redis protocol | Filas de jobs assíncronos |

---

## Fluxo de Autenticação Detalhado

### Validação de Token (todos os serviços)

```
1. Cliente envia: Authorization: Bearer <token>

2. Serviço receptor (ex: evo-core):
   POST http://evo-auth:3001/api/v1/auth/validate
   Headers: Authorization: Bearer <token>

3. evo-auth responde:
   {
     "user": {
       "id": "uuid",
       "name": "string",
       "email": "string",
       "role": "account_owner|agent",
       "type": "user"
     },
     "accounts": [
       { "id": "uuid", "name": "string", "status": "active" }
     ]
   }

4. Serviço injeta dados no contexto da requisição e processa
```

---

## Fluxo de Execução de Agente IA

```
1. Cliente (frontend) solicita sessão de chat
   → evo-gateway → evo-crm

2. evo-crm identifica agente configurado para a inbox
   → GET http://evo-core:5555/api/v1/agents/:id

3. evo-crm despacha mensagem para bot runtime
   → POST http://evo-bot-runtime:8080/...

4. evo-bot-runtime processa com debouncing
   → POST http://evo-processor:8000/...

5. evo-processor executa agente IA:
   → Busca definição do agente: GET evo-core/agents/:id
   → Busca ferramentas: GET evo-core/custom-tools
   → Executa LLM (OpenAI, Anthropic, etc.)
   → Chama ferramentas HTTP se necessário
   → Integra servidores MCP se configurado

6. Resultado retorna:
   evo-processor → evo-bot-runtime → evo-crm
   evo-crm atualiza conversa e notifica cliente
```

---

## Variáveis de Integração Inter-Serviços

```env
# evo-core precisa
EVO_AUTH_BASE_URL=http://evo-auth:3001
EVOLUTION_BASE_URL=http://evo-crm:3000
AI_PROCESSOR_URL=http://evo-processor:8000

# evo-crm precisa
EVO_AUTH_SERVICE_URL=http://evo-auth:3001
EVO_AI_CORE_SERVICE_URL=http://evo-core:5555
BOT_RUNTIME_URL=http://evo-bot-runtime:8080
BOT_RUNTIME_POSTBACK_BASE_URL=http://evo-crm:3000

# evo-processor precisa
EVO_AI_CRM_URL=http://evo-crm:3000
CORE_SERVICE_URL=http://evo-core:5555/api/v1

# evo-bot-runtime precisa
AI_PROCESSOR_URL=http://evo-processor:8000
```

---

## Banco de Dados Compartilhado

Todos os serviços Rails e Go compartilham o mesmo servidor PostgreSQL:

```
postgres:5432/evo_community
├── [Rails schema auth]    → gerenciado por evo-auth migrations
├── [Rails schema crm]     → gerenciado por evo-crm migrations  
├── evo_core_*             → gerenciado por evo-core migrations (golang-migrate)
└── [alembic schema]       → gerenciado por evo-processor migrations (alembic)
```

**Chave estrangeira crítica (futura):**
```sql
-- evo-core referencia accounts do evo-crm
ALTER TABLE evo_core_agents
  ADD COLUMN account_id UUID REFERENCES accounts(id) ON DELETE CASCADE;
```

---

## Redis (Uso por Serviço)

| Serviço | DB Redis | Uso |
|---------|----------|-----|
| `evo-auth` + `evo-auth-sidekiq` | DB 1 | Filas Sidekiq, sessões |
| `evo-crm` + `evo-crm-sidekiq` | DB 0 | Filas Sidekiq, cache |
| `evo-processor` | DB 0 | Cache de sessões IA |
| `evo-bot-runtime` | DB padrão | Estado de debouncing |

---

## Considerações de Resiliência

- Todos os serviços têm `restart: unless-stopped` em produção
- Healthchecks configurados no PostgreSQL, Redis, evo-auth e evo-crm
- `evo-core` e `evo-processor` não expõem portas publicamente (apenas via gateway)
- Jobs de inicialização (`*_init`) rodam uma única vez e não reiniciam automaticamente
