# Admin API Endpoints - Evo CRM

**Data:** 2026-04-29  
**Versão:** 1.0.0

---

## 📋 Visão Geral

Esta documentação descreve os endpoints de administração do Evo CRM, organizados por nível de acesso:

1. **Super Admin** - Gerenciamento global de accounts
2. **Account Owner** - Gerenciamento de usuários da account
3. **Account User** - Visualização de permissões

---

## 🔐 Autenticação

Todos os endpoints requerem autenticação via Bearer Token:

```http
Authorization: Bearer <token>
```

### Headers Opcionais

**X-Account-Id:** Permite Super Admin selecionar uma account específica
```http
X-Account-Id: <uuid>
```

---

## 🔴 Super Admin Endpoints

### 1. Listar Todas as Accounts

Lista todas as accounts do sistema.

**Endpoint:** `GET /api/v1/admin/accounts`  
**Permissão:** `super_admin`

**Response 200:**
```json
{
  "accounts": [
    {
      "id": "00000000-0000-0000-0000-000000000001",
      "name": "Default Account",
      "status": "active",
      "created_at": "2026-04-29T10:00:00Z",
      "updated_at": "2026-04-29T10:00:00Z"
    },
    {
      "id": "11111111-1111-1111-1111-111111111111",
      "name": "Acme Corp",
      "status": "active",
      "created_at": "2026-04-29T11:00:00Z",
      "updated_at": "2026-04-29T11:00:00Z"
    }
  ],
  "total": 2
}
```

**Response 403:**
```json
{
  "error": "Access denied: super_admin role required"
}
```

---

### 2. Criar Nova Account

Cria uma nova account no sistema.

**Endpoint:** `POST /api/v1/admin/accounts`  
**Permissão:** `super_admin`

**Request Body:**
```json
{
  "name": "New Company",
  "status": "active"
}
```

**Campos:**
- `name` (string, required): Nome da account
- `status` (string, optional): Status inicial (default: "active")
  - Valores: `active`, `inactive`, `suspended`

**Response 201:**
```json
{
  "message": "Account created successfully",
  "account": {
    "id": "22222222-2222-2222-2222-222222222222",
    "name": "New Company",
    "status": "active",
    "created_at": "2026-04-29T12:00:00Z",
    "updated_at": "2026-04-29T12:00:00Z"
  }
}
```

**Response 400:**
```json
{
  "error": "Key: 'CreateAccountRequest.Name' Error:Field validation for 'Name' failed on the 'required' tag"
}
```

---

### 3. Obter Estatísticas da Account

Retorna estatísticas detalhadas de uma account específica.

**Endpoint:** `GET /api/v1/admin/accounts/:id/stats`  
**Permissão:** `super_admin`

**Path Parameters:**
- `id` (uuid): ID da account

**Response 200:**
```json
{
  "account_id": "11111111-1111-1111-1111-111111111111",
  "account_name": "Acme Corp",
  "total_agents": 15,
  "total_custom_tools": 8,
  "total_api_keys": 3,
  "total_folders": 5,
  "total_folder_shares": 2,
  "total_mcp_servers": 4,
  "total_integrations": 6,
  "created_at": "2026-04-29T11:00:00Z"
}
```

**Response 404:**
```json
{
  "error": "Account not found"
}
```

---

### 4. Atualizar Status da Account

Atualiza o status de uma account (ativar, desativar, suspender).

**Endpoint:** `PATCH /api/v1/admin/accounts/:id/status`  
**Permissão:** `super_admin`

**Path Parameters:**
- `id` (uuid): ID da account

**Request Body:**
```json
{
  "status": "suspended"
}
```

**Campos:**
- `status` (string, required): Novo status
  - Valores: `active`, `inactive`, `suspended`

**Response 200:**
```json
{
  "message": "Account status updated successfully",
  "status": "suspended"
}
```

**Response 400:**
```json
{
  "error": "Key: 'UpdateAccountStatusRequest.Status' Error:Field validation for 'Status' failed on the 'oneof' tag"
}
```

---

### 5. Contar Recursos da Account

Retorna a contagem de recursos antes de deletar uma account.

**Endpoint:** `GET /api/v1/admin/accounts/:id/resources-count`  
**Permissão:** `super_admin`

**Path Parameters:**
- `id` (uuid): ID da account

**Response 200:**
```json
{
  "account_id": "11111111-1111-1111-1111-111111111111",
  "resource_count": {
    "agents": 15,
    "custom_tools": 8,
    "api_keys": 3,
    "folders": 5,
    "folder_shares": 2,
    "mcp_servers": 4,
    "integrations": 6
  },
  "total_resources": 43,
  "warning": "Deleting this account will permanently delete all associated resources"
}
```

---

## 🟡 Account Owner Endpoints

### 6. Obter Informações da Account

Retorna informações da account do usuário autenticado.

**Endpoint:** `GET /api/v1/account/info`  
**Permissão:** `viewer` (qualquer usuário autenticado)

**Response 200:**
```json
{
  "id": "11111111-1111-1111-1111-111111111111",
  "name": "Acme Corp",
  "status": "active",
  "created_at": "2026-04-29T11:00:00Z",
  "updated_at": "2026-04-29T11:00:00Z"
}
```

**Response 400:**
```json
{
  "error": "No account context"
}
```

---

### 7. Obter Estatísticas da Minha Account

Retorna estatísticas da account do usuário autenticado.

**Endpoint:** `GET /api/v1/account/stats`  
**Permissão:** `viewer` (qualquer usuário autenticado)

**Response 200:**
```json
{
  "account_id": "11111111-1111-1111-1111-111111111111",
  "account_name": "Acme Corp",
  "total_agents": 15,
  "total_custom_tools": 8,
  "total_api_keys": 3,
  "total_folders": 5,
  "total_folder_shares": 2,
  "total_mcp_servers": 4,
  "total_integrations": 6,
  "created_at": "2026-04-29T11:00:00Z"
}
```

---

## 🟢 Account User Endpoints

### 8. Obter Minhas Permissões

Retorna as permissões do usuário autenticado.

**Endpoint:** `GET /api/v1/account/my-permissions`  
**Permissão:** `viewer` (qualquer usuário autenticado)

**Response 200:**
```json
{
  "user_id": "33333333-3333-3333-3333-333333333333",
  "email": "user@acmecorp.com",
  "account_id": "11111111-1111-1111-1111-111111111111",
  "role": "account_user",
  "permission": "editor",
  "capabilities": {
    "can_read": true,
    "can_create": true,
    "can_update": true,
    "can_delete": false,
    "can_manage_users": false,
    "can_manage_accounts": false
  }
}
```

**Exemplo - Super Admin:**
```json
{
  "user_id": "44444444-4444-4444-4444-444444444444",
  "email": "admin@evocrm.com",
  "account_id": "00000000-0000-0000-0000-000000000000",
  "role": "super_admin",
  "permission": "",
  "capabilities": {
    "can_read": true,
    "can_create": true,
    "can_update": true,
    "can_delete": true,
    "can_manage_users": true,
    "can_manage_accounts": true
  }
}
```

**Exemplo - Account Owner:**
```json
{
  "user_id": "55555555-5555-5555-5555-555555555555",
  "email": "owner@acmecorp.com",
  "account_id": "11111111-1111-1111-1111-111111111111",
  "role": "account_owner",
  "permission": "",
  "capabilities": {
    "can_read": true,
    "can_create": true,
    "can_update": true,
    "can_delete": true,
    "can_manage_users": true,
    "can_manage_accounts": false
  }
}
```

**Exemplo - Viewer:**
```json
{
  "user_id": "66666666-6666-6666-6666-666666666666",
  "email": "viewer@acmecorp.com",
  "account_id": "11111111-1111-1111-1111-111111111111",
  "role": "account_user",
  "permission": "viewer",
  "capabilities": {
    "can_read": true,
    "can_create": false,
    "can_update": false,
    "can_delete": false,
    "can_manage_users": false,
    "can_manage_accounts": false
  }
}
```

---

## 📊 Matriz de Permissões

| Role / Permission | Read | Create | Update | Delete | Manage Users | Manage Accounts |
|-------------------|------|--------|--------|--------|--------------|-----------------|
| **super_admin** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **account_owner** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **account_user (account_admin)** | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ |
| **account_user (editor)** | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **account_user (viewer)** | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |

---

## 🧪 Exemplos de Uso

### Exemplo 1: Super Admin Lista Todas as Accounts

```bash
curl -X GET http://localhost:8080/api/v1/admin/accounts \
  -H "Authorization: Bearer <super_admin_token>"
```

### Exemplo 2: Super Admin Cria Nova Account

```bash
curl -X POST http://localhost:8080/api/v1/admin/accounts \
  -H "Authorization: Bearer <super_admin_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Company",
    "status": "active"
  }'
```

### Exemplo 3: Super Admin Obtém Estatísticas de uma Account

```bash
curl -X GET http://localhost:8080/api/v1/admin/accounts/11111111-1111-1111-1111-111111111111/stats \
  -H "Authorization: Bearer <super_admin_token>"
```

### Exemplo 4: Super Admin Suspende uma Account

```bash
curl -X PATCH http://localhost:8080/api/v1/admin/accounts/11111111-1111-1111-1111-111111111111/status \
  -H "Authorization: Bearer <super_admin_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "suspended"
  }'
```

### Exemplo 5: Account Owner Vê Estatísticas da Própria Account

```bash
curl -X GET http://localhost:8080/api/v1/account/stats \
  -H "Authorization: Bearer <account_owner_token>"
```

### Exemplo 6: Account User Vê Suas Permissões

```bash
curl -X GET http://localhost:8080/api/v1/account/my-permissions \
  -H "Authorization: Bearer <account_user_token>"
```

### Exemplo 7: Super Admin Acessa Account Específica

```bash
curl -X GET http://localhost:8080/api/v1/agents \
  -H "Authorization: Bearer <super_admin_token>" \
  -H "X-Account-Id: 11111111-1111-1111-1111-111111111111"
```

---

## 🔒 Códigos de Status HTTP

| Código | Descrição |
|--------|-----------|
| 200 | Sucesso |
| 201 | Criado com sucesso |
| 400 | Requisição inválida |
| 401 | Não autenticado |
| 403 | Acesso negado (permissão insuficiente) |
| 404 | Recurso não encontrado |
| 500 | Erro interno do servidor |

---

## 📚 Referências

- **Middleware de Autorização:** `internal/middleware/authorization.go`
- **Handler Admin:** `internal/handler/admin_handler.go`
- **Rotas Admin:** `internal/routes/admin_routes.go`
- **Context Utils:** `internal/utils/contextutils/tenant.go`

---

**Última Atualização:** 2026-04-29  
**Responsável:** Equipe de Desenvolvimento Evo CRM
