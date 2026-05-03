# Script de Verificação Simples - Multi-Tenant Admin
# Data: 02/05/2026

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Verificação Multi-Tenant Admin" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar serviços Docker
Write-Host "1. Verificando serviços Docker..." -ForegroundColor Yellow
Write-Host ""

$services = @("evo-evo-auth-1", "evo-evo-frontend-1", "evo-evo-gateway-1", "evo-evo-core-1")
foreach ($service in $services) {
    $running = docker ps --format "{{.Names}}" | Select-String -Pattern "^$service$"
    if ($running) {
        Write-Host "  ✓ $service está rodando" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $service NÃO está rodando" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 2. Verificar arquivos do frontend
Write-Host "2. Verificando arquivos do frontend..." -ForegroundColor Yellow
Write-Host ""

$files = @(
    "evo-ai-frontend-community-main/src/services/admin/accountsService.ts",
    "evo-ai-frontend-community-main/src/pages/Admin/Accounts/AccountsList.tsx",
    "evo-ai-frontend-community-main/src/pages/Admin/Accounts/CreateAccount.tsx",
    "evo-ai-frontend-community-main/src/pages/Admin/Accounts/AccountDetails.tsx",
    "evo-ai-frontend-community-main/src/pages/Admin/Accounts/index.ts"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "  ✓ $(Split-Path $file -Leaf) existe" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $(Split-Path $file -Leaf) NÃO existe" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 3. Verificar configuração do menu
Write-Host "3. Verificando configuração do menu..." -ForegroundColor Yellow
Write-Host ""

$menuFile = "evo-ai-frontend-community-main/src/components/layout/config/menuItems.ts"
if (Test-Path $menuFile) {
    $menuContent = Get-Content $menuFile -Raw
    
    if ($menuContent -match "manageAccounts") {
        Write-Host "  ✓ Item 'manageAccounts' encontrado" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Item 'manageAccounts' NÃO encontrado" -ForegroundColor Red
    }
    
    if ($menuContent -match "Building2") {
        Write-Host "  ✓ Ícone 'Building2' encontrado" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Ícone 'Building2' NÃO encontrado" -ForegroundColor Red
    }
    
    if ($menuContent -match "requiredRoleKey: 'super_admin'") {
        Write-Host "  ✓ Restrição 'super_admin' encontrada" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Restrição 'super_admin' NÃO encontrada" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Arquivo menuItems.ts não existe" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 4. Verificar traduções
Write-Host "4. Verificando traduções..." -ForegroundColor Yellow
Write-Host ""

$ptBRFile = "evo-ai-frontend-community-main/src/i18n/locales/pt-BR/layout.json"
$enFile = "evo-ai-frontend-community-main/src/i18n/locales/en/layout.json"

if (Test-Path $ptBRFile) {
    $ptBRContent = Get-Content $ptBRFile -Raw
    if ($ptBRContent -match "manageAccounts") {
        Write-Host "  ✓ Tradução PT-BR encontrada" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Tradução PT-BR NÃO encontrada" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Arquivo PT-BR não existe" -ForegroundColor Red
}

if (Test-Path $enFile) {
    $enContent = Get-Content $enFile -Raw
    if ($enContent -match "manageAccounts") {
        Write-Host "  ✓ Tradução EN encontrada" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Tradução EN NÃO encontrada" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Arquivo EN não existe" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 5. Verificar rotas
Write-Host "5. Verificando rotas do frontend..." -ForegroundColor Yellow
Write-Host ""

$routesFile = "evo-ai-frontend-community-main/src/routes/index.tsx"
if (Test-Path $routesFile) {
    $routesContent = Get-Content $routesFile -Raw
    
    if ($routesContent -match "/admin/accounts") {
        Write-Host "  ✓ Rotas /admin/accounts encontradas" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Rotas /admin/accounts NÃO encontradas" -ForegroundColor Red
    }
    
    if ($routesContent -match "AccountsList") {
        Write-Host "  ✓ Componente AccountsList importado" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Componente AccountsList NÃO importado" -ForegroundColor Red
    }
    
    if ($routesContent -match "CreateAccount") {
        Write-Host "  ✓ Componente CreateAccount importado" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Componente CreateAccount NÃO importado" -ForegroundColor Red
    }
    
    if ($routesContent -match "AccountDetails") {
        Write-Host "  ✓ Componente AccountDetails importado" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Componente AccountDetails NÃO importado" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Arquivo de rotas não existe" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 6. Resumo
Write-Host "6. PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Para testar a interface completa:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Acesse: http://localhost:5173/login" -ForegroundColor White
Write-Host "  2. Login: tonygomes058@gmail.com" -ForegroundColor White
Write-Host "  3. Senha: To811205ny@" -ForegroundColor White
Write-Host "  4. Procure 'Gerenciar Empresas' no menu lateral" -ForegroundColor White
Write-Host ""
Write-Host "Documentação completa:" -ForegroundColor Cyan
Write-Host "  - TESTE_MULTI_TENANT_ADMIN.md (guia de testes)" -ForegroundColor White
Write-Host "  - IMPLEMENTACAO_MULTI_TENANT_COMPLETA.md (documentação técnica)" -ForegroundColor White
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
