# Script de Verificação da Implementação Multi-Tenant Admin
# Data: 02/05/2026

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Verificação Multi-Tenant Admin" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar se os serviços estão rodando
Write-Host "1. Verificando serviços Docker..." -ForegroundColor Yellow
Write-Host ""

$services = @("evo-evo-auth-1", "evo-evo-frontend-1", "evo-evo-gateway-1", "evo-evo-core-1")

foreach ($service in $services) {
    $running = docker ps --format "{{.Names}}" | Select-String -Pattern "^$service$"
    if ($running) {
        Write-Host "✓ $service está rodando" -ForegroundColor Green
    } else {
        Write-Host "✗ $service NÃO está rodando" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 2. Verificar role do usuário super_admin
Write-Host "2. Verificando role do usuário super_admin..." -ForegroundColor Yellow
Write-Host ""

$checkRole = @"
user = User.find_by(email: 'tonygomes058@gmail.com')
if user
  roles = user.roles.pluck(:key).join(', ')
  if roles.include?('super_admin')
    puts '✓ Usuário tonygomes058@gmail.com tem role super_admin'
  else
    puts '✗ Usuário tonygomes058@gmail.com NÃO tem role super_admin'
    puts \"  Roles atuais: #{roles}\"
  end
else
  puts '✗ Usuário tonygomes058@gmail.com não encontrado'
end
"@

docker exec evo-evo-auth-1 bundle exec rails runner $checkRole 2>$null

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 3. Verificar se as roles existem
Write-Host "3. Verificando roles no sistema..." -ForegroundColor Yellow
Write-Host ""

$checkRoles = @"
roles = Role.all.pluck(:key, :name, :type)
puts 'Roles disponíveis:'
roles.each do |key, name, type|
  puts \"  - #{key}: #{name} (#{type})\"
end
"@

docker exec evo-evo-auth-1 bundle exec rails runner $checkRoles 2>$null

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 4. Verificar arquivos do frontend
Write-Host "4. Verificando arquivos do frontend..." -ForegroundColor Yellow
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
        Write-Host "✓ $file existe" -ForegroundColor Green
    } else {
        Write-Host "✗ $file NÃO existe" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 5. Verificar se o menu foi atualizado
Write-Host "5. Verificando configuração do menu..." -ForegroundColor Yellow
Write-Host ""

$menuFile = "evo-ai-frontend-community-main/src/components/layout/config/menuItems.ts"
$menuContent = Get-Content $menuFile -Raw

if ($menuContent -match "manageAccounts") {
    Write-Host "✓ Item 'manageAccounts' encontrado no menuItems.ts" -ForegroundColor Green
} else {
    Write-Host "✗ Item 'manageAccounts' NÃO encontrado no menuItems.ts" -ForegroundColor Red
}

if ($menuContent -match "Building2") {
    Write-Host "✓ Ícone 'Building2' encontrado no menuItems.ts" -ForegroundColor Green
} else {
    Write-Host "✗ Ícone 'Building2' NÃO encontrado no menuItems.ts" -ForegroundColor Red
}

if ($menuContent -match "requiredRoleKey: 'super_admin'") {
    Write-Host "✓ Restrição 'requiredRoleKey: super_admin' encontrada" -ForegroundColor Green
} else {
    Write-Host "✗ Restrição 'requiredRoleKey: super_admin' NÃO encontrada" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 6. Verificar traduções
Write-Host "6. Verificando traduções..." -ForegroundColor Yellow
Write-Host ""

$ptBRFile = "evo-ai-frontend-community-main/src/i18n/locales/pt-BR/layout.json"
$enFile = "evo-ai-frontend-community-main/src/i18n/locales/en/layout.json"

if (Test-Path $ptBRFile) {
    $ptBRContent = Get-Content $ptBRFile -Raw
    if ($ptBRContent -match "manageAccounts") {
        Write-Host "✓ Tradução PT-BR encontrada" -ForegroundColor Green
    } else {
        Write-Host "✗ Tradução PT-BR NÃO encontrada" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Arquivo de tradução PT-BR não existe" -ForegroundColor Red
}

if (Test-Path $enFile) {
    $enContent = Get-Content $enFile -Raw
    if ($enContent -match "manageAccounts") {
        Write-Host "✓ Tradução EN encontrada" -ForegroundColor Green
    } else {
        Write-Host "✗ Tradução EN NÃO encontrada" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Arquivo de tradução EN não existe" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 7. Verificar rotas
Write-Host "7. Verificando rotas do frontend..." -ForegroundColor Yellow
Write-Host ""

$routesFile = "evo-ai-frontend-community-main/src/routes/index.tsx"
if (Test-Path $routesFile) {
    $routesContent = Get-Content $routesFile -Raw
    
    if ($routesContent -match "/admin/accounts") {
        Write-Host "✓ Rotas /admin/accounts encontradas" -ForegroundColor Green
    } else {
        Write-Host "✗ Rotas /admin/accounts NÃO encontradas" -ForegroundColor Red
    }
    
    if ($routesContent -match "AccountsList") {
        Write-Host "✓ Componente AccountsList importado" -ForegroundColor Green
    } else {
        Write-Host "✗ Componente AccountsList NÃO importado" -ForegroundColor Red
    }
} else {
    Write-Host "✗ Arquivo de rotas não existe" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 8. URLs para testes manuais
Write-Host "8. URLs para testes manuais:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Frontend: http://localhost:5173" -ForegroundColor Cyan
Write-Host "Login: http://localhost:5173/login" -ForegroundColor Cyan
Write-Host "Admin Accounts: http://localhost:5173/admin/accounts" -ForegroundColor Cyan
Write-Host "Gateway API: http://localhost:3030" -ForegroundColor Cyan
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 9. Resumo
Write-Host "9. Resumo da Verificação:" -ForegroundColor Yellow
Write-Host ""
Write-Host "✓ = Verificação passou" -ForegroundColor Green
Write-Host "✗ = Verificação falhou" -ForegroundColor Red
Write-Host ""
Write-Host "Para testar a interface:" -ForegroundColor Cyan
Write-Host "1. Acesse: http://localhost:5173/login"
Write-Host "2. Login: tonygomes058@gmail.com / To811205ny@"
Write-Host "3. Procure o item 'Gerenciar Empresas' no menu lateral"
Write-Host ""
Write-Host "Para mais detalhes, consulte: TESTE_MULTI_TENANT_ADMIN.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
