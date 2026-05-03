# Guia de Testes - Multi-Tenant Admin Interface

**Data**: 02/05/2026  
**Status**: ✅ **PRONTO PARA TESTES**

---

## 📋 Resumo da Implementação

A implementação do sistema multi-tenant admin está **100% COMPLETA**:

✅ **Backend**: Roles, endpoints e autorização  
✅ **Database**: Migration 000017 aplicada  
✅ **Frontend**: Interface completa de gerenciamento  
✅ **Menu**: Visível apenas para super_admin  
✅ **Traduções**: PT-BR e EN  
✅ **Serviços**: Todos rodando (frontend reiniciado)

---

## 🎯 Objetivos dos Testes

1. **Verificar Visibilidade do Menu**: Confirmar que "Gerenciar Empresas" aparece apenas para super_admin
2. **Testar Criação de Empresa**: Criar uma nova empresa com administrador
3. **Testar Listagem**: Visualizar todas as empresas cadastradas
4. **Testar Detalhes**: Ver informações completas de uma empresa
5. **Testar Isolamento**: Confirmar que usuários não-admin não veem o menu

---

## 🚀 Passo a Passo dos Testes

### Teste 1: Login como Super Admin

**Objetivo**: Verificar que o menu "Gerenciar Empresas" aparece para super_admin

**Passos**:
1. Abra o navegador e acesse: `http://localhost:5173/login`
2. Faça login com as credenciais:
   - **Email**: `tonygomes058@gmail.com`
   - **Senha**: `To811205ny@`
3. Aguarde o redirecionamento para o dashboard

**Resultado Esperado**:
- ✅ Login bem-sucedido
- ✅ Redirecionamento para `/dashboard`
- ✅ Menu lateral carregado

---

### Teste 2: Verificar Menu "Gerenciar Empresas"

**Objetivo**: Confirmar que o item de menu está visível e funcional

**Passos**:
1. No menu lateral esquerdo, procure pelo item **"Gerenciar Empresas"**
2. Verifique o ícone (deve ser um prédio/building)
3. Clique no item do menu

**Resultado Esperado**:
- ✅ Item "Gerenciar Empresas" está visível no menu
- ✅ Ícone de prédio (Building2) aparece ao lado do texto
- ✅ Ao clicar, redireciona para `/admin/accounts`
- ✅ Página de listagem de empresas é carregada

**Screenshot Sugerido**: Tire um print do menu lateral mostrando o item

---

### Teste 3: Visualizar Listagem de Empresas

**Objetivo**: Verificar a página de listagem de empresas

**Passos**:
1. Na página `/admin/accounts`, observe a interface
2. Verifique os elementos da página:
   - Título "Gerenciar Empresas"
   - Botão "Nova Empresa"
   - Tabela de empresas (pode estar vazia)

**Resultado Esperado**:
- ✅ Título "Gerenciar Empresas" com ícone de prédio
- ✅ Botão "Nova Empresa" no canto superior direito
- ✅ Se houver empresas: tabela com colunas (Nome, Domínio, Email de Suporte, Status, Criado em, Ações)
- ✅ Se não houver empresas: mensagem "Nenhuma empresa cadastrada" com botão "Criar Primeira Empresa"

**Screenshot Sugerido**: Tire um print da página de listagem

---

### Teste 4: Criar Nova Empresa

**Objetivo**: Testar o formulário de criação de empresa

**Passos**:
1. Clique no botão **"Nova Empresa"**
2. Preencha o formulário com os seguintes dados:

   **Seção "Dados da Empresa"**:
   - **Nome da Empresa**: `Empresa Teste 1`
   - **Domínio** (opcional): `teste1.com`
   - **Email de Suporte**: `suporte@teste1.com`
   - **Idioma**: `Português (Brasil)`

   **Seção "Administrador da Empresa"**:
   - **Nome**: `Admin Teste`
   - **Email**: `admin@teste1.com`
   - **Senha**: `Senha123!`
   - **Confirmar Senha**: `Senha123!`

3. Clique no botão **"Criar Empresa"**

**Resultado Esperado**:
- ✅ Formulário é exibido corretamente com duas seções
- ✅ Validações funcionam (campos obrigatórios, formato de email, senha mínima 8 caracteres)
- ✅ Ao clicar em "Criar Empresa", mostra loading
- ✅ Após criação bem-sucedida:
  - Alerta de sucesso: "Empresa criada com sucesso!"
  - Redirecionamento para `/admin/accounts`
  - Nova empresa aparece na listagem

**Possíveis Erros**:
- ❌ Se aparecer erro 403 (Forbidden): Verificar se o token de autenticação está sendo enviado
- ❌ Se aparecer erro 500: Verificar logs do backend (Auth Service)
- ❌ Se aparecer erro de validação: Verificar se todos os campos obrigatórios foram preenchidos

**Screenshot Sugerido**: Tire prints do formulário preenchido e da mensagem de sucesso

---

### Teste 5: Visualizar Detalhes da Empresa

**Objetivo**: Testar a página de detalhes de uma empresa

**Passos**:
1. Na listagem de empresas, clique no ícone de **"Ver Detalhes"** (ícone de olho) da empresa criada
2. Observe a página de detalhes

**Resultado Esperado**:
- ✅ Redirecionamento para `/admin/accounts/:id`
- ✅ Informações da empresa exibidas:
  - Nome
  - Domínio
  - Email de Suporte
  - Idioma
  - Status
  - Data de Criação
- ✅ Card de estatísticas mostrando:
  - Total de Usuários
  - Total de Agentes
  - Total de Conversas
- ✅ Tabela de usuários da empresa mostrando:
  - Nome
  - Email
  - Roles (com chips coloridos)
  - Status de confirmação
- ✅ Botão "Voltar" funcional

**Screenshot Sugerido**: Tire um print da página de detalhes

---

### Teste 6: Testar Isolamento de Permissões

**Objetivo**: Confirmar que usuários não-super_admin NÃO veem o menu

**Passos**:
1. Faça logout da conta super_admin
2. Faça login com outro usuário (se houver) que NÃO seja super_admin
   - Ou crie um novo usuário via interface de usuários
3. Verifique o menu lateral

**Resultado Esperado**:
- ✅ Item "Gerenciar Empresas" **NÃO aparece** no menu
- ✅ Tentativa de acessar `/admin/accounts` diretamente deve resultar em:
  - Redirecionamento para página de erro
  - Ou mensagem de "Acesso negado"

**Screenshot Sugerido**: Tire um print do menu sem o item "Gerenciar Empresas"

---

## 🔍 Testes de API (Opcional - Via Postman/Insomnia)

### 1. Obter Token de Autenticação

```bash
POST http://localhost:3030/api/v1/auth/login
Content-Type: application/json

{
  "email": "tonygomes058@gmail.com",
  "password": "To811205ny@"
}
```

**Resposta Esperada**:
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

Copie o `token` para usar nos próximos testes.

---

### 2. Listar Todas as Empresas

```bash
GET http://localhost:3030/api/v1/admin/accounts
Authorization: Bearer <TOKEN>
```

**Resposta Esperada**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Empresa Teste 1",
      "domain": "teste1.com",
      "support_email": "suporte@teste1.com",
      "locale": "pt-BR",
      "status": "active",
      "created_at": "2026-05-02T...",
      "updated_at": "2026-05-02T..."
    }
  ]
}
```

---

### 3. Criar Nova Empresa

```bash
POST http://localhost:3030/api/v1/admin/accounts
Authorization: Bearer <TOKEN>
Content-Type: application/json

{
  "account": {
    "name": "Empresa Teste 2",
    "domain": "teste2.com",
    "support_email": "suporte@teste2.com",
    "locale": "pt-BR"
  },
  "admin": {
    "name": "Admin Teste 2",
    "email": "admin@teste2.com",
    "password": "Senha123!",
    "password_confirmation": "Senha123!"
  }
}
```

**Resposta Esperada**:
```json
{
  "success": true,
  "message": "Account and admin user created successfully",
  "data": {
    "account": { ... },
    "admin": { ... }
  }
}
```

---

### 4. Obter Detalhes de uma Empresa

```bash
GET http://localhost:3030/api/v1/admin/accounts/:id
Authorization: Bearer <TOKEN>
```

**Resposta Esperada**:
```json
{
  "success": true,
  "data": {
    "account": { ... },
    "users": [ ... ],
    "stats": {
      "users_count": 1,
      "agents_count": 0,
      "conversations_count": 0
    }
  }
}
```

---

### 5. Listar Usuários de uma Empresa

```bash
GET http://localhost:3030/api/v1/admin/accounts/:id/users
Authorization: Bearer <TOKEN>
```

**Resposta Esperada**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Admin Teste",
      "email": "admin@teste1.com",
      "confirmed_at": "2026-05-02T...",
      "roles": [
        {
          "key": "account_admin",
          "name": "Account Admin"
        }
      ],
      "created_at": "2026-05-02T...",
      "updated_at": "2026-05-02T..."
    }
  ]
}
```

---

## 🐛 Troubleshooting

### Problema: Menu "Gerenciar Empresas" não aparece

**Possíveis Causas**:
1. Usuário não tem role `super_admin`
2. Frontend não foi reiniciado após as mudanças
3. Cache do navegador

**Soluções**:
```bash
# 1. Verificar role do usuário
docker exec -it evo-evo-auth-1 bundle exec rails runner "
  user = User.find_by(email: 'tonygomes058@gmail.com')
  puts \"Roles: #{user.roles.pluck(:key).join(', ')}\"
"

# 2. Reiniciar frontend
docker restart evo-evo-frontend-1

# 3. Limpar cache do navegador (Ctrl+Shift+Delete)
```

---

### Problema: Erro 403 (Forbidden) ao acessar endpoints

**Possíveis Causas**:
1. Token de autenticação não está sendo enviado
2. Token expirado
3. Usuário não tem permissão super_admin

**Soluções**:
```bash
# 1. Verificar se o token está sendo enviado no header Authorization
# 2. Fazer login novamente para obter novo token
# 3. Verificar permissões do usuário (ver comando acima)
```

---

### Problema: Erro 500 ao criar empresa

**Possíveis Causas**:
1. Validação de dados falhou no backend
2. Email do admin já existe
3. Erro de conexão com banco de dados

**Soluções**:
```bash
# Verificar logs do Auth Service
docker logs evo-evo-auth-1 --tail 50

# Verificar se o email já existe
docker exec -it evo-evo-auth-1 bundle exec rails runner "
  puts User.find_by(email: 'admin@teste1.com').present? ? 'Email já existe' : 'Email disponível'
"
```

---

### Problema: Página em branco ou erro de carregamento

**Possíveis Causas**:
1. Componente React com erro
2. Rota não configurada corretamente
3. Erro de importação

**Soluções**:
```bash
# 1. Verificar console do navegador (F12)
# 2. Verificar logs do frontend
docker logs evo-evo-frontend-1 --tail 50

# 3. Reiniciar frontend
docker restart evo-evo-frontend-1
```

---

## ✅ Checklist de Testes

Use este checklist para acompanhar o progresso dos testes:

### Testes de Interface
- [ ] Login como super_admin bem-sucedido
- [ ] Menu "Gerenciar Empresas" visível
- [ ] Ícone de prédio aparece no menu
- [ ] Clique no menu redireciona para `/admin/accounts`
- [ ] Página de listagem carrega corretamente
- [ ] Botão "Nova Empresa" funcional
- [ ] Formulário de criação exibido corretamente
- [ ] Validações de formulário funcionam
- [ ] Criação de empresa bem-sucedida
- [ ] Redirecionamento após criação funciona
- [ ] Nova empresa aparece na listagem
- [ ] Clique em "Ver Detalhes" funciona
- [ ] Página de detalhes exibe informações corretas
- [ ] Estatísticas são exibidas
- [ ] Tabela de usuários é exibida
- [ ] Botão "Voltar" funcional

### Testes de Permissões
- [ ] Logout de super_admin funcional
- [ ] Login com usuário não-admin funcional
- [ ] Menu "Gerenciar Empresas" NÃO aparece para não-admin
- [ ] Acesso direto a `/admin/accounts` é bloqueado para não-admin

### Testes de API (Opcional)
- [ ] Login via API retorna token
- [ ] GET `/api/v1/admin/accounts` retorna lista
- [ ] POST `/api/v1/admin/accounts` cria empresa
- [ ] GET `/api/v1/admin/accounts/:id` retorna detalhes
- [ ] GET `/api/v1/admin/accounts/:id/users` retorna usuários

---

## 📊 Relatório de Testes

Após completar os testes, preencha este relatório:

**Data dos Testes**: _______________  
**Testador**: _______________  
**Navegador**: _______________  
**Versão do Sistema**: 1.0.0

### Resultados

| Teste | Status | Observações |
|-------|--------|-------------|
| Login super_admin | ⬜ Passou / ⬜ Falhou | |
| Menu visível | ⬜ Passou / ⬜ Falhou | |
| Listagem de empresas | ⬜ Passou / ⬜ Falhou | |
| Criação de empresa | ⬜ Passou / ⬜ Falhou | |
| Detalhes da empresa | ⬜ Passou / ⬜ Falhou | |
| Isolamento de permissões | ⬜ Passou / ⬜ Falhou | |

### Bugs Encontrados

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Sugestões de Melhoria

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

---

## 🎯 Próximos Passos Após os Testes

Se todos os testes passarem:

1. ✅ **Documentar**: Atualizar documentação com screenshots
2. ✅ **Comunicar**: Informar equipe que o sistema está pronto
3. ✅ **Treinar**: Preparar material de treinamento para usuários
4. ✅ **Monitorar**: Acompanhar uso inicial e coletar feedback

Se houver falhas:

1. ❌ **Documentar Bugs**: Registrar todos os problemas encontrados
2. ❌ **Priorizar**: Classificar bugs por severidade
3. ❌ **Corrigir**: Implementar correções necessárias
4. ❌ **Re-testar**: Executar testes novamente após correções

---

## 📞 Suporte

Em caso de dúvidas ou problemas durante os testes:

1. Consulte a documentação completa: `IMPLEMENTACAO_MULTI_TENANT_COMPLETA.md`
2. Verifique os logs dos serviços (comandos acima)
3. Entre em contato com a equipe de desenvolvimento

---

**Última Atualização**: 02/05/2026  
**Responsável**: Tony Gomes  
**Status**: ✅ PRONTO PARA TESTES
