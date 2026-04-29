# Evo Core Service — API Contracts

**Base URL**: `http://localhost:5555`  
**Autenticação**: Bearer Token em todas as rotas protegidas  
**Formato**: JSON

---

## Rotas Públicas (sem autenticação)

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/health` | Health check |
| GET | `/ready` | Readiness check |
| GET | `/metrics` | Métricas Prometheus (se habilitado) |

**Resposta health:**
```json
{ "status": "ok" }
```

---

## Rotas Protegidas

**Prefixo**: `/api/v1`  
**Header obrigatório**: `Authorization: Bearer {token}`

---

### Agents (`/api/v1/agents`)

Gerenciamento de agentes IA.

#### `GET /api/v1/agents`
Lista todos os agentes.

**Response 200:**
```json
[
  {
    "id": "uuid",
    "account_id": "uuid",
    "name": "string",
    "description": "string",
    "type": "string",
    "created_at": "ISO8601",
    "updated_at": "ISO8601"
  }
]
```

#### `POST /api/v1/agents`
Cria um novo agente.

**Request body:**
```json
{
  "name": "string (required)",
  "description": "string",
  "type": "string"
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "name": "string",
  "description": "string",
  "created_at": "ISO8601"
}
```

#### `GET /api/v1/agents/:id`
Retorna um agente pelo ID.

**Response 200:** objeto Agent  
**Response 404:** `{ "error": "not found" }`

#### `PUT /api/v1/agents/:id`
Atualiza um agente existente.

**Request body:** campos parciais do Agent  
**Response 200:** objeto Agent atualizado

#### `DELETE /api/v1/agents/:id`
Remove um agente.

**Response 204:** sem body  
**Response 404:** `{ "error": "not found" }`

---

### Custom Tools (`/api/v1/custom-tools`)

Ferramentas HTTP customizadas para uso pelos agentes.

#### `GET /api/v1/custom-tools`
Lista todas as ferramentas.

#### `POST /api/v1/custom-tools`
Cria uma nova ferramenta customizada.

**Request body:**
```json
{
  "name": "string (required)",
  "description": "string",
  "url": "string (required)",
  "method": "GET|POST|PUT|DELETE|PATCH",
  "headers": {},
  "body": {}
}
```

#### `GET /api/v1/custom-tools/:id`
Retorna uma ferramenta pelo ID.

#### `PUT /api/v1/custom-tools/:id`
Atualiza uma ferramenta.

#### `DELETE /api/v1/custom-tools/:id`
Remove uma ferramenta.

#### `GET /api/v1/custom-tools/:id/test`
Executa um teste da ferramenta customizada.

**Response 200:**
```json
{
  "success": true,
  "status_code": 200,
  "response": {}
}
```

---

### API Keys (`/api/v1/apikeys`)

Armazenamento criptografado de credenciais de API.

> ⚠️ Os valores são criptografados com Fernet antes de persistir.

#### `GET /api/v1/apikeys`
Lista todas as chaves API (valores mascarados).

**Response 200:**
```json
[
  {
    "id": "uuid",
    "name": "string",
    "provider": "string",
    "value": "***",
    "created_at": "ISO8601"
  }
]
```

#### `POST /api/v1/apikeys`
Cria uma nova chave API.

**Request body:**
```json
{
  "name": "string (required)",
  "provider": "string",
  "value": "string (required, será criptografado)"
}
```

#### `PUT /api/v1/apikeys/:id`
Atualiza uma chave API.

#### `DELETE /api/v1/apikeys/:id`
Remove uma chave API.

---

### Folders (`/api/v1/folders`)

Organização de workspace por pastas.

#### `GET /api/v1/folders`
Lista todas as pastas.

#### `GET /api/v1/folders/accessible-folders`
Lista pastas acessíveis pelo usuário atual (incluindo compartilhadas).

#### `POST /api/v1/folders`
Cria uma nova pasta.

**Request body:**
```json
{
  "name": "string (required)",
  "description": "string",
  "parent_id": "uuid (opcional)"
}
```

#### `PUT /api/v1/folders/:id`
Atualiza uma pasta.

#### `DELETE /api/v1/folders/:id`
Remove uma pasta e seus recursos.

---

### MCP Servers (`/api/v1/mcp-servers`)

Registro de servidores Model Context Protocol.

#### `GET /api/v1/mcp-servers`
Lista servidores MCP disponíveis.

#### `POST /api/v1/mcp-servers`
Registra um novo servidor MCP.

**Request body:**
```json
{
  "name": "string (required)",
  "url": "string (required)",
  "description": "string",
  "config": {}
}
```

#### `GET /api/v1/mcp-servers/:id`
Retorna detalhes de um servidor MCP.

#### `PUT /api/v1/mcp-servers/:id`
Atualiza um servidor MCP.

#### `DELETE /api/v1/mcp-servers/:id`
Remove um servidor MCP.

---

### Custom MCP Servers (`/api/v1/custom-mcp-servers`)

Servidores MCP customizados por tenant/usuário.

Mesmos endpoints que `/api/v1/mcp-servers`, mas com escopo por usuário/account.

---

## Códigos de Erro Padrão

| Código | Significado |
|--------|-------------|
| 400 | Requisição inválida (body malformado, campo obrigatório ausente) |
| 401 | Token ausente ou inválido |
| 403 | Sem permissão para o recurso |
| 404 | Recurso não encontrado |
| 429 | Rate limit excedido |
| 500 | Erro interno do servidor |

**Formato de erro:**
```json
{
  "error": "mensagem descritiva"
}
```

---

## Autenticação — Detalhes Técnicos

### Headers suportados

```http
Authorization: Bearer {access_token}
```

**Alternativo (fallback):**
```http
api_access_token: {token}
HTTP_API_ACCESS_TOKEN: {token}
```

### Endpoint de validação (evo-auth)

```
POST http://evo-auth:3001/api/v1/auth/validate
Headers: Authorization: Bearer {token}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "name": "string",
    "email": "string",
    "role": "account_owner|agent",
    "type": "user"
  },
  "accounts": [
    {
      "id": "uuid",
      "name": "string",
      "status": "active"
    }
  ]
}
```
