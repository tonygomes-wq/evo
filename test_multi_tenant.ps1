# Script de Teste Multi-Tenant - Evo CRM
# PowerShell Script para Windows

$ErrorActionPreference = "Continue"

# Configurações
$BASE_URL = "http://localhost:5555"
$AUTH_URL = "http://localhost:3001"

# Cores para output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Yellow }
function Write-Step { Write-Host "`n=== $args ===" -ForegroundColor Cyan }

Write-Step "Teste Multi-Tenant Evo CRM"

# 1. Login
Write-Info "`n1. Fazendo login no EvoAuth..."
Write-Host "   URL: $AUTH_URL/api/v1/auth/login"
Write-Host "   Credenciais: Você precisa fornecer email e senha válidos"
Write-Host ""

$email = Read-Host "   Digite o email"
$password = Read-Host "   Digite a senha" -AsSecureString
$passwordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

$loginBody = @{
    email = $email
    password = $passwordPlain
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$AUTH_URL/api/v1/auth/login" `
        -Method Post `
        -ContentType "application/json" `
        -Body $loginBody
    
    $TOKEN = $loginResponse.data.token
    $USER_ID = $loginResponse.data.user.id
    $USER_ROLE = $loginResponse.data.user.role
    
    Write-Success "✅ Login realizado com sucesso"
    Write-Host "   User ID: $USER_ID"
    Write-Host "   Role: $USER_ROLE"
    Write-Host "   Token: $($TOKEN.Substring(0, 20))..."
} catch {
    Write-Error "❌ Falha no login: $_"
    Write-Host "   Verifique se o serviço evo-auth está rodando:"
    Write-Host "   docker ps | Select-String 'evo-auth'"
    exit 1
}

# Headers padrão
$headers = @{
    "Authorization" = "Bearer $TOKEN"
    "Content-Type" = "application/json"
}

# 2. Testar Health Check
Write-Step "2. Testando Health Check"
try {
    $health = Invoke-RestMethod -Uri "$BASE_URL/health" -Method Get
    Write-Success "✅ Health check OK"
} catch {
    Write-Error "❌ Health check falhou: $_"
}

# 3. Listar Agents Existentes
Write-Step "3. Listando agents existentes"
try {
    $agents = Invoke-RestMethod -Uri "$BASE_URL/api/v1/agents" `
        -Method Get `
        -Headers $headers
    
    $total = $agents.data.total
    Write-Success "✅ Total de agents: $total"
    
    if ($total -gt 0) {
        Write-Host "`n   Agents encontrados:"
        foreach ($agent in $agents.data.agents) {
            Write-Host "   - $($agent.name) (ID: $($agent.id), Account: $($agent.account_id))"
        }
    }
} catch {
    Write-Error "❌ Falha ao listar agents: $_"
}

# 4. Criar Account A (apenas Super Admin)
if ($USER_ROLE -eq "super_admin") {
    Write-Step "4. Criando Account A (Super Admin)"
    
    $accountABody = @{
        name = "Empresa A - Tecnologia"
        status = "active"
    } | ConvertTo-Json
    
    try {
        $accountA = Invoke-RestMethod -Uri "$BASE_URL/api/v1/admin/accounts" `
            -Method Post `
            -Headers $headers `
            -Body $accountABody
        
        $ACCOUNT_A_ID = $accountA.account.id
        Write-Success "✅ Account A criada: $ACCOUNT_A_ID"
    } catch {
        Write-Error "❌ Falha ao criar Account A: $_"
        Write-Info "   Nota: Endpoint admin pode não estar registrado ainda"
    }
    
    # 5. Criar Account B
    Write-Step "5. Criando Account B"
    
    $accountBBody = @{
        name = "Empresa B - Consultoria"
        status = "active"
    } | ConvertTo-Json
    
    try {
        $accountB = Invoke-RestMethod -Uri "$BASE_URL/api/v1/admin/accounts" `
            -Method Post `
            -Headers $headers `
            -Body $accountBBody
        
        $ACCOUNT_B_ID = $accountB.account.id
        Write-Success "✅ Account B criada: $ACCOUNT_B_ID"
    } catch {
        Write-Error "❌ Falha ao criar Account B: $_"
    }
    
    # 6. Criar Agent na Account A
    if ($ACCOUNT_A_ID) {
        Write-Step "6. Criando Agent na Account A"
        
        $headersA = $headers.Clone()
        $headersA["X-Tenant-ID"] = $ACCOUNT_A_ID
        
        $agentABody = @{
            name = "Agent da Empresa A"
            type = "chat"
            description = "Agent exclusivo da Empresa A"
            system_prompt = "Você é um assistente da Empresa A."
            model = "gpt-4"
            temperature = 0.7
        } | ConvertTo-Json
        
        try {
            $agentA = Invoke-RestMethod -Uri "$BASE_URL/api/v1/agents" `
                -Method Post `
                -Headers $headersA `
                -Body $agentABody
            
            $AGENT_A_ID = $agentA.data.id
            Write-Success "✅ Agent A criado: $AGENT_A_ID"
        } catch {
            Write-Error "❌ Falha ao criar Agent A: $_"
        }
    }
    
    # 7. Criar Agent na Account B
    if ($ACCOUNT_B_ID) {
        Write-Step "7. Criando Agent na Account B"
        
        $headersB = $headers.Clone()
        $headersB["X-Tenant-ID"] = $ACCOUNT_B_ID
        
        $agentBBody = @{
            name = "Agent da Empresa B"
            type = "chat"
            description = "Agent exclusivo da Empresa B"
            system_prompt = "Você é um assistente da Empresa B."
            model = "gpt-4"
            temperature = 0.7
        } | ConvertTo-Json
        
        try {
            $agentB = Invoke-RestMethod -Uri "$BASE_URL/api/v1/agents" `
                -Method Post `
                -Headers $headersB `
                -Body $agentBBody
            
            $AGENT_B_ID = $agentB.data.id
            Write-Success "✅ Agent B criado: $AGENT_B_ID"
        } catch {
            Write-Error "❌ Falha ao criar Agent B: $_"
        }
    }
    
    # 8. Testar Isolamento
    if ($ACCOUNT_A_ID -and $AGENT_A_ID) {
        Write-Step "8. Testando Isolamento de Tenant"
        
        $headersA = $headers.Clone()
        $headersA["X-Tenant-ID"] = $ACCOUNT_A_ID
        
        try {
            $agentsA = Invoke-RestMethod -Uri "$BASE_URL/api/v1/agents" `
                -Method Get `
                -Headers $headersA
            
            $totalA = $agentsA.data.total
            Write-Success "✅ Account A vê $totalA agent(s)"
            
            if ($totalA -eq 1) {
                Write-Success "   ✓ Isolamento funcionando corretamente"
            } else {
                Write-Error "   ✗ Esperado 1 agent, encontrado $totalA"
            }
        } catch {
            Write-Error "❌ Falha ao testar isolamento: $_"
        }
    }
    
    # 9. Testar Acesso Cross-Tenant (deve falhar)
    if ($ACCOUNT_A_ID -and $AGENT_B_ID) {
        Write-Step "9. Testando Acesso Cross-Tenant (deve falhar)"
        
        $headersA = $headers.Clone()
        $headersA["X-Tenant-ID"] = $ACCOUNT_A_ID
        
        try {
            $crossAccess = Invoke-RestMethod -Uri "$BASE_URL/api/v1/agents/$AGENT_B_ID" `
                -Method Get `
                -Headers $headersA `
                -ErrorAction Stop
            
            Write-Error "❌ Acesso cross-tenant PERMITIDO (FALHA DE SEGURANÇA!)"
        } catch {
            if ($_.Exception.Response.StatusCode -eq 404 -or $_.Exception.Response.StatusCode -eq 403) {
                Write-Success "✅ Acesso cross-tenant BLOQUEADO (correto)"
            } else {
                Write-Error "❌ Erro inesperado: $_"
            }
        }
    }
    
    # 10. Listar Todas as Accounts
    Write-Step "10. Listando Todas as Accounts (Super Admin)"
    try {
        $allAccounts = Invoke-RestMethod -Uri "$BASE_URL/api/v1/admin/accounts" `
            -Method Get `
            -Headers $headers
        
        Write-Success "✅ Total de accounts: $($allAccounts.total)"
        Write-Host "`n   Accounts:"
        foreach ($acc in $allAccounts.accounts) {
            Write-Host "   - $($acc.name) (ID: $($acc.id), Status: $($acc.status))"
        }
    } catch {
        Write-Error "❌ Falha ao listar accounts: $_"
        Write-Info "   Nota: Endpoint admin pode não estar registrado ainda"
    }
    
} else {
    Write-Info "`n4-10. Testes de Super Admin pulados (usuário não é super_admin)"
    Write-Host "   Role atual: $USER_ROLE"
}

# 11. Criar Agent Simples
Write-Step "11. Criando Agent Simples"

$simpleAgentBody = @{
    name = "Agent de Teste - $(Get-Date -Format 'HH:mm:ss')"
    type = "chat"
    description = "Agent criado pelo script de teste"
    system_prompt = "Você é um assistente útil."
    model = "gpt-4"
    temperature = 0.7
} | ConvertTo-Json

try {
    $simpleAgent = Invoke-RestMethod -Uri "$BASE_URL/api/v1/agents" `
        -Method Post `
        -Headers $headers `
        -Body $simpleAgentBody
    
    $SIMPLE_AGENT_ID = $simpleAgent.data.id
    $SIMPLE_AGENT_ACCOUNT = $simpleAgent.data.account_id
    
    Write-Success "✅ Agent criado com sucesso"
    Write-Host "   ID: $SIMPLE_AGENT_ID"
    Write-Host "   Account ID: $SIMPLE_AGENT_ACCOUNT"
    Write-Host "   Nome: $($simpleAgent.data.name)"
} catch {
    Write-Error "❌ Falha ao criar agent: $_"
}

# 12. Obter Minhas Permissões
Write-Step "12. Obtendo Minhas Permissões"
try {
    $permissions = Invoke-RestMethod -Uri "$BASE_URL/api/v1/account/my-permissions" `
        -Method Get `
        -Headers $headers
    
    Write-Success "✅ Permissões obtidas"
    Write-Host "`n   User ID: $($permissions.user_id)"
    Write-Host "   Email: $($permissions.email)"
    Write-Host "   Account ID: $($permissions.account_id)"
    Write-Host "   Role: $($permissions.role)"
    Write-Host "   Permission: $($permissions.permission)"
    Write-Host "`n   Capacidades:"
    Write-Host "   - Ler: $($permissions.capabilities.can_read)"
    Write-Host "   - Criar: $($permissions.capabilities.can_create)"
    Write-Host "   - Atualizar: $($permissions.capabilities.can_update)"
    Write-Host "   - Deletar: $($permissions.capabilities.can_delete)"
    Write-Host "   - Gerenciar Usuários: $($permissions.capabilities.can_manage_users)"
    Write-Host "   - Gerenciar Accounts: $($permissions.capabilities.can_manage_accounts)"
} catch {
    Write-Error "❌ Falha ao obter permissões: $_"
    Write-Info "   Nota: Endpoint pode não estar registrado ainda"
}

# 13. Obter Info da Account
Write-Step "13. Obtendo Informações da Account"
try {
    $accountInfo = Invoke-RestMethod -Uri "$BASE_URL/api/v1/account/info" `
        -Method Get `
        -Headers $headers
    
    Write-Success "✅ Informações da account obtidas"
    Write-Host "   ID: $($accountInfo.id)"
    Write-Host "   Nome: $($accountInfo.name)"
    Write-Host "   Status: $($accountInfo.status)"
    Write-Host "   Criada em: $($accountInfo.created_at)"
} catch {
    Write-Error "❌ Falha ao obter info da account: $_"
    Write-Info "   Nota: Endpoint pode não estar registrado ainda"
}

# Resumo Final
Write-Step "Resumo dos Testes"

Write-Host "`n✅ Testes Concluídos" -ForegroundColor Green
Write-Host "`nPróximos Passos:"
Write-Host "1. Verifique os logs do container: docker logs evo-crm-community-main-evo-core-1"
Write-Host "2. Consulte o guia completo: GUIA_TESTES_LOCAL.md"
Write-Host "3. Veja a documentação: MULTI_TENANT_IMPLEMENTATION_COMPLETE.md"

Write-Host "`n" -NoNewline
Read-Host "Pressione Enter para sair"
