#!/bin/bash

# Script de Verificação da Implementação Multi-Tenant Admin
# Data: 02/05/2026

echo "=========================================="
echo "Verificação Multi-Tenant Admin"
echo "=========================================="
echo ""

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Verificar se os serviços estão rodando
echo "1. Verificando serviços Docker..."
echo ""

SERVICES=("evo-evo-auth-1" "evo-evo-frontend-1" "evo-evo-gateway-1" "evo-evo-core-1")

for service in "${SERVICES[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^${service}$"; then
        echo -e "${GREEN}✓${NC} $service está rodando"
    else
        echo -e "${RED}✗${NC} $service NÃO está rodando"
    fi
done

echo ""
echo "=========================================="
echo ""

# 2. Verificar role do usuário super_admin
echo "2. Verificando role do usuário super_admin..."
echo ""

docker exec -it evo-evo-auth-1 bundle exec rails runner "
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
" 2>/dev/null

echo ""
echo "=========================================="
echo ""

# 3. Verificar se as roles existem
echo "3. Verificando roles no sistema..."
echo ""

docker exec -it evo-evo-auth-1 bundle exec rails runner "
  roles = Role.all.pluck(:key, :name, :type)
  puts 'Roles disponíveis:'
  roles.each do |key, name, type|
    puts \"  - #{key}: #{name} (#{type})\"
  end
" 2>/dev/null

echo ""
echo "=========================================="
echo ""

# 4. Verificar arquivos do frontend
echo "4. Verificando arquivos do frontend..."
echo ""

FILES=(
    "evo-ai-frontend-community-main/src/services/admin/accountsService.ts"
    "evo-ai-frontend-community-main/src/pages/Admin/Accounts/AccountsList.tsx"
    "evo-ai-frontend-community-main/src/pages/Admin/Accounts/CreateAccount.tsx"
    "evo-ai-frontend-community-main/src/pages/Admin/Accounts/AccountDetails.tsx"
    "evo-ai-frontend-community-main/src/pages/Admin/Accounts/index.ts"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file existe"
    else
        echo -e "${RED}✗${NC} $file NÃO existe"
    fi
done

echo ""
echo "=========================================="
echo ""

# 5. Verificar se o menu foi atualizado
echo "5. Verificando configuração do menu..."
echo ""

if grep -q "manageAccounts" "evo-ai-frontend-community-main/src/components/layout/config/menuItems.ts"; then
    echo -e "${GREEN}✓${NC} Item 'manageAccounts' encontrado no menuItems.ts"
else
    echo -e "${RED}✗${NC} Item 'manageAccounts' NÃO encontrado no menuItems.ts"
fi

if grep -q "Building2" "evo-ai-frontend-community-main/src/components/layout/config/menuItems.ts"; then
    echo -e "${GREEN}✓${NC} Ícone 'Building2' encontrado no menuItems.ts"
else
    echo -e "${RED}✗${NC} Ícone 'Building2' NÃO encontrado no menuItems.ts"
fi

if grep -q "requiredRoleKey: 'super_admin'" "evo-ai-frontend-community-main/src/components/layout/config/menuItems.ts"; then
    echo -e "${GREEN}✓${NC} Restrição 'requiredRoleKey: super_admin' encontrada"
else
    echo -e "${RED}✗${NC} Restrição 'requiredRoleKey: super_admin' NÃO encontrada"
fi

echo ""
echo "=========================================="
echo ""

# 6. Verificar traduções
echo "6. Verificando traduções..."
echo ""

if grep -q "manageAccounts" "evo-ai-frontend-community-main/src/i18n/locales/pt-BR/layout.json"; then
    echo -e "${GREEN}✓${NC} Tradução PT-BR encontrada"
else
    echo -e "${RED}✗${NC} Tradução PT-BR NÃO encontrada"
fi

if grep -q "manageAccounts" "evo-ai-frontend-community-main/src/i18n/locales/en/layout.json"; then
    echo -e "${GREEN}✓${NC} Tradução EN encontrada"
else
    echo -e "${RED}✗${NC} Tradução EN NÃO encontrada"
fi

echo ""
echo "=========================================="
echo ""

# 7. Verificar rotas
echo "7. Verificando rotas do frontend..."
echo ""

if grep -q "/admin/accounts" "evo-ai-frontend-community-main/src/routes/index.tsx"; then
    echo -e "${GREEN}✓${NC} Rotas /admin/accounts encontradas"
else
    echo -e "${RED}✗${NC} Rotas /admin/accounts NÃO encontradas"
fi

if grep -q "AccountsList" "evo-ai-frontend-community-main/src/routes/index.tsx"; then
    echo -e "${GREEN}✓${NC} Componente AccountsList importado"
else
    echo -e "${RED}✗${NC} Componente AccountsList NÃO importado"
fi

echo ""
echo "=========================================="
echo ""

# 8. Verificar migration 000017
echo "8. Verificando migration 000017 no Core Service..."
echo ""

docker exec -it evo-evo-core-1 psql -U postgres -d evo_core_development -c "
SELECT COUNT(*) as total_indexes 
FROM pg_indexes 
WHERE indexname LIKE '%account_id%';
" 2>/dev/null | grep -E "^\s+[0-9]+" | awk '{print $1}' | while read count; do
    if [ "$count" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Migration 000017 aplicada ($count índices com account_id encontrados)"
    else
        echo -e "${YELLOW}⚠${NC} Nenhum índice com account_id encontrado (migration pode não ter sido aplicada)"
    fi
done

echo ""
echo "=========================================="
echo ""

# 9. Testar endpoint de listagem (requer token)
echo "9. URLs para testes manuais:"
echo ""
echo "Frontend: http://localhost:5173"
echo "Login: http://localhost:5173/login"
echo "Admin Accounts: http://localhost:5173/admin/accounts"
echo "Gateway API: http://localhost:3030"
echo ""

echo "=========================================="
echo ""

# 10. Resumo
echo "10. Resumo da Verificação:"
echo ""
echo -e "${GREEN}✓${NC} = Verificação passou"
echo -e "${RED}✗${NC} = Verificação falhou"
echo -e "${YELLOW}⚠${NC} = Atenção necessária"
echo ""
echo "Para testar a interface:"
echo "1. Acesse: http://localhost:5173/login"
echo "2. Login: tonygomes058@gmail.com / To811205ny@"
echo "3. Procure o item 'Gerenciar Empresas' no menu lateral"
echo ""
echo "Para mais detalhes, consulte: TESTE_MULTI_TENANT_ADMIN.md"
echo ""
echo "=========================================="
