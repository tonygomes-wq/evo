# Guia de Testes Local - Multi-Tenant Evo CRM

**Data:** 2026-04-30  
**Ambiente:** Docker Local (localhost)

---

## 🔑 1. Obter Token de Autenticação

### Passo 1: Fazer Login no EvoAuth

```bash
# Login via API do EvoAuth
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "sua_senha_aqui"
  }'
```

**Resposta esperada:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "email": "admin@example.com",
      "role": "super_admin"
    },
    "accounts": [
      {
        "id": "00000000-0000-0000-0000-000000000001",
        "name": "Default Account"
      }
    ]
  }
}
```

### Passo 2: Salvar o Token

```bash
# Salvar em variável de ambiente (Linux/Mac)
export TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Salvar em variável de ambiente (Windows PowerShell)
$env:TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## 🧪 2. Testes Básicos da API

### Teste 1: Health Check (sem autenticação)

```bash
curl http://localhost:5555/health
```

**Resposta esperada:**
```json
{
  "status": "healthy",
  "timestamp": "2026-04-30T00:00:00Z"
}
```

### Teste 2: Listar Agents (com autenticação)

```bash
curl -X GET http://localhost:5555/api/v1/agents \
  -H "Authorization: Bearer $TOKEN"
```

**Resposta esperada:**
```json
{
  "success": true,
  "data": {
    "agents": [],
    "total": 0
  }
}
```

### Teste 3: Criar um Agent

```bash
curl -X POST http://localhost:5555/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Assistente de Teste",
    "type": "chat",
    "description": "Agent criado para teste de multi-tenancy",
    "system_prompt": "Você é um assistente útil.",
    "model": "gpt-4",
    "temperature": 0.7
  }'
```

**Resposta esperada:**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Assistente de Teste",
    "type": "chat",
    "account_id": "00000000-0000-0000-0000-000000000001",
    "created_at": "2026-04-30T00:00:00Z"
  }
}
```

---

## 🔐 3. Testes de Isolamento Multi-Tenant

### Cenário: Criar 2 Accounts e Testar Isolamento

#### Passo 1: Login como Super Admin

```bash
# Usar o token do Super Admin obtido anteriormente
export SUPER_ADMIN_TOKEN="$TOKEN"
```

#### Passo 2: Criar Account A

```bash
curl -X POST http://localhost:5555/api/v1/admin/accounts \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Empresa A - Tecnologia",
    "status": "active"
  }'
```

**Resposta esperada:**
```json
{
  "message": "Account created successfully",
  "account": {
    "id": "11111111-1111-1111-1111-111111111111",
    "name": "Empresa A - Tecnologia",
    "status": "active",
    "created_at": "2026-04-30T00:00:00Z"
  }
}
```

#### Passo 3: Criar Account B

```bash
curl -X POST http://localhost:5555/api/v1/admin/accounts \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Empresa B - Consultoria",
    "status": "active"
  }'
```

**Resposta esperada:**
```json
{
  "message": "Account created successfully",
  "account": {
    "id": "22222222-2222-2222-2222-222222222222",
    "name": "Empresa B - Consultoria",
    "status": "active",
    "created_at": "2026-04-30T00:00:00Z"
  }
}
```

#### Passo 4: Criar Agent na Account A

```bash
curl -X POST http://localhost:5555/api/v1/agents \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "X-Tenant-ID: 11111111-1111-1111-1111-111111111111" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Agent da Empresa A",
    "type": "chat",
    "description": "Agent exclusivo da Empresa A",
    "system_prompt": "Você é um assistente da Empresa A.",
    "model": "gpt-4"
  }'
```

**Resposta esperada:**
```json
{
  "success": true,
  "data": {
    "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
    "name": "Agent da Empresa A",
    "account_id": "11111111-1111-1111-1111-111111111111",
    "created_at": "2026-04-30T00:00:00Z"
  }
}
```

#### Passo 5: Criar Agent na Account B

```bash
curl -X POST http://localhost:5555/api/v1/agents \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "X-Tenant-ID: 22222222-2222-2222-2222-222222222222" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Agent da Empresa B",
    "type": "chat",
    "description": "Agent exclusivo da Empresa B",
    "system_prompt": "Você é um assistente da Empresa B.",
    "model": "gpt-4"
  }'
```

**Resposta esperada:**
```json
{
  "success": true,
  "data": {
    "id": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
    "name": "Agent da Empresa B",
    "account_id": "22222222-2222-2222-2222-222222222222",
    "created_at": "2026-04-30T00:00:00Z"
  }
}
```

#### Passo 6: Testar Isolamento - Account A não vê Agent da Account B

```bash
# Listar agents da Account A
curl -X GET http://localhost:5555/api/v1/agents \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "X-Tenant-ID: 11111111-1111-1111-1111-111111111111"
```

**Resposta esperada (apenas Agent da Account A):**
```json
{
  "success": true,
  "data": {
    "agents": [
      {
        "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        "name": "Agent da Empresa A",
        "account_id": "11111111-1111-1111-1111-111111111111"
      }
    ],
    "total": 1
  }
}
```

#### Passo 7: Tentar Acessar Agent da Account B usando Account A (deve falhar)

```bash
curl -X GET http://localhost:5555/api/v1/agents/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "X-Tenant-ID: 11111111-1111-1111-1111-111111111111"
```

**Resposta esperada (404 - não encontrado):**
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Agent not found"
  }
}
```

---

## 👥 4. Testes de Permissões

### Cenário: Testar diferentes níveis de permissão

#### Viewer (somente leitura)

```bash
# Simular token de Viewer
# Nota: O token deve ter role="account_user" e permission="viewer"

curl -X GET http://localhost:5555/api/v1/agents \
  -H "Authorization: Bearer $VIEWER_TOKEN"
# ✅ Deve funcionar

curl -X POST http://localhost:5555/api/v1/agents \
  -H "Authorization: Bearer $VIEWER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Teste", "type": "chat"}'
# ❌ Deve retornar 403 Forbidden
```

#### Editor (leitura e escrita)

```bash
# Simular token de Editor
# Nota: O token deve ter role="account_user" e permission="editor"

curl -X POST http://localhost:5555/api/v1/agents \
  -H "Authorization: Bearer $EDITOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Agent do Editor", "type": "chat"}'
# ✅ Deve funcionar

curl -X DELETE http://localhost:5555/api/v1/agents/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa \
  -H "Authorization: Bearer $EDITOR_TOKEN"
# ❌ Deve retornar 403 Forbidden (apenas account_admin pode deletar)
```

#### Account Admin (tudo exceto gerenciar usuários)

```bash
# Simular token de Account Admin
# Nota: O token deve ter role="account_user" e permission="account_admin"

curl -X DELETE http://localhost:5555/api/v1/agents/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa \
  -H "Authorization: Bearer $ACCOUNT_ADMIN_TOKEN"
# ✅ Deve funcionar
```

---

## 📊 5. Testes de Endpoints Admin

### Listar Todas as Accounts (Super Admin)

```bash
curl -X GET http://localhost:5555/api/v1/admin/accounts \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN"
```

**Resposta esperada:**
```json
{
  "accounts": [
    {
      "id": "00000000-0000-0000-0000-000000000001",
      "name": "Default Account",
      "status": "active",
      "created_at": "2026-04-29T00:00:00Z"
    },
    {
      "id": "11111111-1111-1111-1111-111111111111",
      "name": "Empresa A - Tecnologia",
      "status": "active",
      "created_at": "2026-04-30T00:00:00Z"
    },
    {
      "id": "22222222-2222-2222-2222-222222222222",
      "name": "Empresa B - Consultoria",
      "status": "active",
      "created_at": "2026-04-30T00:00:00Z"
    }
  ],
  "total": 3
}
```

### Obter Estatísticas de uma Account

```bash
curl -X GET http://localhost:5555/api/v1/admin/accounts/11111111-1111-1111-1111-111111111111/stats \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN"
```

**Resposta esperada:**
```json
{
  "account_id": "11111111-1111-1111-1111-111111111111",
  "account_name": "Empresa A - Tecnologia",
  "total_agents": 1,
  "total_custom_tools": 0,
  "total_api_keys": 0,
  "total_folders": 0,
  "total_folder_shares": 0,
  "total_mcp_servers": 0,
  "total_integrations": 0,
  "created_at": "2026-04-30T00:00:00Z"
}
```

### Atualizar Status de uma Account

```bash
curl -X PATCH http://localhost:5555/api/v1/admin/accounts/11111111-1111-1111-1111-111111111111/status \
  -H "Authorization: Bearer $SUPER_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "suspended"
  }'
```

**Resposta esperada:**
```json
{
  "message": "Account status updated successfully",
  "status": "suspended"
}
```

### Obter Informações da Minha Account (Account Owner)

```bash
curl -X GET http://localhost:5555/api/v1/account/info \
  -H "Authorization: Bearer $TOKEN"
```

**Resposta esperada:**
```json
{
  "id": "00000000-0000-0000-0000-000000000001",
  "name": "Default Account",
  "status": "active",
  "created_at": "2026-04-29T00:00:00Z"
}
```

### Obter Minhas Permissões

```bash
curl -X GET http://localhost:5555/api/v1/account/my-permissions \
  -H "Authorization: Bearer $TOKEN"
```

**Resposta esperada:**
```json
{
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "admin@example.com",
  "account_id": "00000000-0000-0000-0000-000000000001",
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

---

## 🗄️ 6. Testes Diretos no Banco de Dados

### Verificar Isolamento no Banco

```bash
# Conectar ao PostgreSQL
docker exec -it evo-crm-community-main-postgres-1 psql -U postgres -d evo_community
```

```sql
-- Ver todas as accounts
SELECT id, name, status, created_at FROM accounts;

-- Ver agents por account
SELECT 
    a.id,
    a.name,
    a.account_id,
    acc.name as account_name
FROM evo_core_agents a
LEFT JOIN accounts acc ON a.account_id = acc.id
ORDER BY a.account_id, a.created_at;

-- Contar recursos por account
SELECT 
    acc.name as account_name,
    COUNT(DISTINCT a.id) as total_agents,
    COUNT(DISTINCT ct.id) as total_custom_tools,
    COUNT(DISTINCT ak.id) as total_api_keys
FROM accounts acc
LEFT JOIN evo_core_agents a ON a.account_id = acc.id
LEFT JOIN evo_core_custom_tools ct ON ct.account_id = acc.id
LEFT JOIN evo_core_api_keys ak ON ak.account_id = acc.id
GROUP BY acc.id, acc.name
ORDER BY acc.name;

-- Verificar índices
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE indexname LIKE '%account_id%'
ORDER BY indexname;

-- Verificar constraints
SELECT conname, contype 
FROM pg_constraint 
WHERE conname LIKE '%account%'
ORDER BY conname;
```

---

## 📝 7. Script de Teste Completo

Salve este script como `test_multi_tenant.sh`:

```bash
#!/bin/bash

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:5555"

echo -e "${YELLOW}=== Teste Multi-Tenant Evo CRM ===${NC}\n"

# 1. Login
echo -e "${YELLOW}1. Fazendo login...${NC}"
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"sua_senha"}')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
    echo -e "${RED}❌ Falha no login${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Login realizado com sucesso${NC}\n"

# 2. Criar Account A
echo -e "${YELLOW}2. Criando Account A...${NC}"
ACCOUNT_A=$(curl -s -X POST $BASE_URL/api/v1/admin/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Empresa A","status":"active"}')

ACCOUNT_A_ID=$(echo $ACCOUNT_A | jq -r '.account.id')
echo -e "${GREEN}✅ Account A criada: $ACCOUNT_A_ID${NC}\n"

# 3. Criar Account B
echo -e "${YELLOW}3. Criando Account B...${NC}"
ACCOUNT_B=$(curl -s -X POST $BASE_URL/api/v1/admin/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Empresa B","status":"active"}')

ACCOUNT_B_ID=$(echo $ACCOUNT_B | jq -r '.account.id')
echo -e "${GREEN}✅ Account B criada: $ACCOUNT_B_ID${NC}\n"

# 4. Criar Agent na Account A
echo -e "${YELLOW}4. Criando Agent na Account A...${NC}"
AGENT_A=$(curl -s -X POST $BASE_URL/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-ID: $ACCOUNT_A_ID" \
  -H "Content-Type: application/json" \
  -d '{"name":"Agent A","type":"chat","model":"gpt-4"}')

AGENT_A_ID=$(echo $AGENT_A | jq -r '.data.id')
echo -e "${GREEN}✅ Agent A criado: $AGENT_A_ID${NC}\n"

# 5. Criar Agent na Account B
echo -e "${YELLOW}5. Criando Agent na Account B...${NC}"
AGENT_B=$(curl -s -X POST $BASE_URL/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-ID: $ACCOUNT_B_ID" \
  -H "Content-Type: application/json" \
  -d '{"name":"Agent B","type":"chat","model":"gpt-4"}')

AGENT_B_ID=$(echo $AGENT_B | jq -r '.data.id')
echo -e "${GREEN}✅ Agent B criado: $AGENT_B_ID${NC}\n"

# 6. Testar Isolamento
echo -e "${YELLOW}6. Testando isolamento...${NC}"
AGENTS_A=$(curl -s -X GET $BASE_URL/api/v1/agents \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-ID: $ACCOUNT_A_ID")

TOTAL_A=$(echo $AGENTS_A | jq -r '.data.total')

if [ "$TOTAL_A" == "1" ]; then
    echo -e "${GREEN}✅ Account A vê apenas 1 agent (correto)${NC}"
else
    echo -e "${RED}❌ Account A vê $TOTAL_A agents (esperado: 1)${NC}"
fi

# 7. Tentar acessar Agent B da Account A (deve falhar)
echo -e "\n${YELLOW}7. Testando acesso cross-tenant (deve falhar)...${NC}"
CROSS_ACCESS=$(curl -s -w "\n%{http_code}" -X GET $BASE_URL/api/v1/agents/$AGENT_B_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Tenant-ID: $ACCOUNT_A_ID")

HTTP_CODE=$(echo "$CROSS_ACCESS" | tail -n1)

if [ "$HTTP_CODE" == "404" ] || [ "$HTTP_CODE" == "403" ]; then
    echo -e "${GREEN}✅ Acesso cross-tenant bloqueado (correto)${NC}"
else
    echo -e "${RED}❌ Acesso cross-tenant permitido (HTTP $HTTP_CODE)${NC}"
fi

echo -e "\n${GREEN}=== Testes Concluídos ===${NC}"
```

**Executar:**
```bash
chmod +x test_multi_tenant.sh
./test_multi_tenant.sh
```

---

## ✅ Checklist de Testes

- [ ] Health check funciona
- [ ] Login retorna token válido
- [ ] Listar agents com autenticação funciona
- [ ] Criar agent injeta account_id automaticamente
- [ ] Criar múltiplas accounts funciona
- [ ] Agents são isolados por account
- [ ] Acesso cross-tenant é bloqueado
- [ ] Super Admin pode acessar todas as accounts
- [ ] Endpoints admin funcionam
- [ ] Estatísticas por account estão corretas
- [ ] Índices estão criados no banco
- [ ] Constraints estão aplicadas

---

## 🐛 Troubleshooting

### Erro: "Authentication token required"

**Solução:** Verifique se o header `Authorization: Bearer $TOKEN` está correto.

### Erro: "Account not found"

**Solução:** Verifique se a account foi criada corretamente e se o ID está correto.

### Erro: "Forbidden"

**Solução:** Verifique se o usuário tem as permissões necessárias para a operação.

### Container evo-core unhealthy

**Solução:** 
```bash
# Ver logs
docker logs evo-crm-community-main-evo-core-1 --tail 100

# Reiniciar
docker restart evo-crm-community-main-evo-core-1
```

---

## 📞 Suporte

Se encontrar problemas, verifique:
1. Logs do container: `docker logs evo-crm-community-main-evo-core-1`
2. Status do banco: `docker exec evo-crm-community-main-postgres-1 pg_isready`
3. Documentação completa: `MULTI_TENANT_IMPLEMENTATION_COMPLETE.md`

---

**Última Atualização:** 2026-04-30  
**Versão:** 1.0
