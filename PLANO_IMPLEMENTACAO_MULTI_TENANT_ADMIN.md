# Plano de Implementação - Sistema Multi-Tenant com Admin

**Data**: 02/05/2026  
**Objetivo**: Implementar interface administrativa para gerenciar empresas/accounts e seus administradores

---

## 📊 Situação Atual

### ✅ O Que JÁ Existe

1. **Backend (Core Service)**:
   - ✅ Middleware de tenant implementado
   - ✅ Banco de dados com `account_id` em todas as tabelas
   - ✅ Repositories filtrando por account
   - ✅ Isolamento de dados funcionando

2. **Auth Service**:
   - ✅ Sistema de autenticação funcionando
   - ✅ Roles básicas: `account_owner` e `agent`
   - ✅ RuntimeConfig com account padrão

3. **Frontend**:
   - ✅ Interface de login funcionando
   - ✅ Tela de gerenciamento de atendentes
   - ❌ **FALTA**: Interface para gerenciar accounts/empresas

### ❌ O Que Falta

1. **Roles e Permissões**:
   - ❌ Role `super_admin` (administrador global)
   - ❌ Hierarquia de permissões clara
   - ❌ Middleware de autorização por role

2. **Endpoints de Administração**:
   - ❌ CRUD de accounts/empresas
   - ❌ Gerenciamento de usuários por account
   - ❌ Atribuição de roles

3. **Interface Frontend**:
   - ❌ Painel de administração global
   - ❌ Tela de criação de empresas
   - ❌ Tela de gerenciamento de administradores

---

## 🚀 Plano de Implementação

### Fase 1: Backend - Roles e Permissões (2-3 dias)

#### 1.1. Criar Role `super_admin` no Auth Service

**Arquivo**: `evo-auth-service-community-main/db/seeds/rbac.rb`

```ruby
# Adicionar role super_admin
Role.find_or_create_by!(key: 'super_admin') do |role|
  role.name = 'Super Admin'
  role.description = 'Global administrator with access to all accounts'
end

# Adicionar role account_admin
Role.find_or_create_by!(key: 'account_admin') do |role|
  role.name = 'Account Admin'
  role.description = 'Administrator of a specific account'
end
```

**Executar seed**:
```bash
docker exec -it evo-evo-auth-1 bundle exec rails db:seed
```

#### 1.2. Atualizar Usuário Atual para Super Admin

```bash
# Via console Rails
docker exec -it evo-evo-auth-1 bundle exec rails console

# No console:
user = User.find_by(email: 'tonygomes058@gmail.com')
super_admin_role = Role.find_by(key: 'super_admin')
UserRole.assign_role_to_user(user, super_admin_role)
puts "✅ Usuário #{user.email} agora é Super Admin"
exit
```

#### 1.3. Criar Endpoints de Administração no Auth Service

**Arquivo**: `evo-auth-service-community-main/app/controllers/api/v1/admin/accounts_controller.rb`

```ruby
# frozen_string_literal: true

module Api
  module V1
    module Admin
      class AccountsController < Api::BaseController
        before_action :authenticate_user!
        before_action :require_super_admin!

        # GET /api/v1/admin/accounts
        def index
          accounts = Account.all.order(created_at: :desc)
          render json: {
            success: true,
            data: accounts.map { |acc| serialize_account(acc) }
          }
        end

        # POST /api/v1/admin/accounts
        def create
          account = Account.new(account_params)
          
          if account.save
            # Criar usuário administrador da account
            admin_user = create_account_admin(account, params[:admin])
            
            render json: {
              success: true,
              data: {
                account: serialize_account(account),
                admin: UserSerializer.full(admin_user)
              }
            }, status: :created
          else
            render json: {
              success: false,
              errors: account.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        # GET /api/v1/admin/accounts/:id
        def show
          account = Account.find(params[:id])
          users = User.joins(:user_roles, :roles)
                      .where(roles: { key: ['account_owner', 'account_admin'] })
                      .distinct
          
          render json: {
            success: true,
            data: {
              account: serialize_account(account),
              users: users.map { |u| UserSerializer.full(u) },
              stats: account_stats(account)
            }
          }
        end

        # PATCH /api/v1/admin/accounts/:id
        def update
          account = Account.find(params[:id])
          
          if account.update(account_params)
            render json: {
              success: true,
              data: serialize_account(account)
            }
          else
            render json: {
              success: false,
              errors: account.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/admin/accounts/:id
        def destroy
          account = Account.find(params[:id])
          
          # Verificar se não é a account padrão
          if account.id == RuntimeConfig.account['id']
            return render json: {
              success: false,
              error: 'Cannot delete default account'
            }, status: :forbidden
          end
          
          account.destroy
          render json: { success: true }
        end

        private

        def require_super_admin!
          unless current_user.has_role?('super_admin')
            render json: {
              success: false,
              error: 'Super admin access required'
            }, status: :forbidden
          end
        end

        def account_params
          params.require(:account).permit(:name, :domain, :support_email, :locale, :status)
        end

        def create_account_admin(account, admin_params)
          user = User.create!(
            name: admin_params[:name],
            email: admin_params[:email],
            password: admin_params[:password],
            password_confirmation: admin_params[:password],
            confirmed_at: Time.current,
            type: 'User'
          )
          
          # Atribuir role account_admin
          role = Role.find_by!(key: 'account_admin')
          UserRole.assign_role_to_user(user, role)
          
          # Associar à account (via RuntimeConfig ou tabela accounts)
          # TODO: Implementar associação user <-> account
          
          user
        end

        def serialize_account(account)
          {
            id: account['id'],
            name: account['name'],
            domain: account['domain'],
            support_email: account['support_email'],
            locale: account['locale'],
            status: account['status'],
            created_at: account['created_at'],
            updated_at: account['updated_at']
          }
        end

        def account_stats(account)
          {
            users_count: 0, # TODO: Implementar contagem
            agents_count: 0, # TODO: Implementar contagem via Core Service
            conversations_count: 0 # TODO: Implementar contagem via CRM
          }
        end
      end
    end
  end
end
```

#### 1.4. Adicionar Rotas no Auth Service

**Arquivo**: `evo-auth-service-community-main/config/routes.rb`

```ruby
# Adicionar dentro de namespace :api do
  namespace :v1 do
    # ... rotas existentes ...
    
    # Admin routes (Super Admin only)
    namespace :admin do
      resources :accounts, only: [:index, :create, :show, :update, :destroy] do
        member do
          get :stats
          get :users
          post 'users/:user_id/assign_role', to: 'accounts#assign_user_role'
        end
      end
    end
  end
end
```

---

### Fase 2: Frontend - Interface Administrativa (3-4 dias)

#### 2.1. Criar Componente de Listagem de Empresas

**Arquivo**: `evo-ai-frontend-community-main/src/pages/Admin/Accounts/AccountsList.jsx`

```jsx
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../../../services/api';

export default function AccountsList() {
  const [accounts, setAccounts] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    loadAccounts();
  }, []);

  const loadAccounts = async () => {
    try {
      const response = await api.get('/api/v1/admin/accounts');
      setAccounts(response.data.data);
    } catch (error) {
      console.error('Erro ao carregar empresas:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateAccount = () => {
    navigate('/admin/accounts/new');
  };

  if (loading) return <div>Carregando...</div>;

  return (
    <div className="accounts-list">
      <div className="header">
        <h1>Gerenciar Empresas</h1>
        <button onClick={handleCreateAccount} className="btn-primary">
          + Nova Empresa
        </button>
      </div>

      <table className="accounts-table">
        <thead>
          <tr>
            <th>Nome</th>
            <th>Domínio</th>
            <th>Email de Suporte</th>
            <th>Status</th>
            <th>Criado em</th>
            <th>Ações</th>
          </tr>
        </thead>
        <tbody>
          {accounts.map(account => (
            <tr key={account.id}>
              <td>{account.name}</td>
              <td>{account.domain}</td>
              <td>{account.support_email}</td>
              <td>
                <span className={`status-badge ${account.status}`}>
                  {account.status}
                </span>
              </td>
              <td>{new Date(account.created_at).toLocaleDateString()}</td>
              <td>
                <button onClick={() => navigate(`/admin/accounts/${account.id}`)}>
                  Ver Detalhes
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
```

#### 2.2. Criar Formulário de Nova Empresa

**Arquivo**: `evo-ai-frontend-community-main/src/pages/Admin/Accounts/CreateAccount.jsx`

```jsx
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../../../services/api';

export default function CreateAccount() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    account: {
      name: '',
      domain: '',
      support_email: '',
      locale: 'pt-BR',
      status: 'active'
    },
    admin: {
      name: '',
      email: '',
      password: '',
      password_confirmation: ''
    }
  });
  const [errors, setErrors] = useState([]);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setErrors([]);

    try {
      await api.post('/api/v1/admin/accounts', formData);
      alert('Empresa criada com sucesso!');
      navigate('/admin/accounts');
    } catch (error) {
      setErrors(error.response?.data?.errors || ['Erro ao criar empresa']);
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (section, field, value) => {
    setFormData(prev => ({
      ...prev,
      [section]: {
        ...prev[section],
        [field]: value
      }
    }));
  };

  return (
    <div className="create-account">
      <h1>Nova Empresa</h1>

      {errors.length > 0 && (
        <div className="alert alert-error">
          {errors.map((error, index) => (
            <p key={index}>{error}</p>
          ))}
        </div>
      )}

      <form onSubmit={handleSubmit}>
        <section className="form-section">
          <h2>Dados da Empresa</h2>
          
          <div className="form-group">
            <label>Nome da Empresa *</label>
            <input
              type="text"
              value={formData.account.name}
              onChange={(e) => handleChange('account', 'name', e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label>Domínio</label>
            <input
              type="text"
              value={formData.account.domain}
              onChange={(e) => handleChange('account', 'domain', e.target.value)}
              placeholder="exemplo.com"
            />
          </div>

          <div className="form-group">
            <label>Email de Suporte *</label>
            <input
              type="email"
              value={formData.account.support_email}
              onChange={(e) => handleChange('account', 'support_email', e.target.value)}
              required
            />
          </div>
        </section>

        <section className="form-section">
          <h2>Administrador da Empresa</h2>
          
          <div className="form-group">
            <label>Nome do Administrador *</label>
            <input
              type="text"
              value={formData.admin.name}
              onChange={(e) => handleChange('admin', 'name', e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label>Email *</label>
            <input
              type="email"
              value={formData.admin.email}
              onChange={(e) => handleChange('admin', 'email', e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label>Senha *</label>
            <input
              type="password"
              value={formData.admin.password}
              onChange={(e) => handleChange('admin', 'password', e.target.value)}
              required
              minLength={8}
            />
          </div>

          <div className="form-group">
            <label>Confirmar Senha *</label>
            <input
              type="password"
              value={formData.admin.password_confirmation}
              onChange={(e) => handleChange('admin', 'password_confirmation', e.target.value)}
              required
              minLength={8}
            />
          </div>
        </section>

        <div className="form-actions">
          <button type="button" onClick={() => navigate('/admin/accounts')}>
            Cancelar
          </button>
          <button type="submit" disabled={loading} className="btn-primary">
            {loading ? 'Criando...' : 'Criar Empresa'}
          </button>
        </div>
      </form>
    </div>
  );
}
```

#### 2.3. Adicionar Rotas no Frontend

**Arquivo**: `evo-ai-frontend-community-main/src/routes/index.jsx`

```jsx
import AccountsList from '../pages/Admin/Accounts/AccountsList';
import CreateAccount from '../pages/Admin/Accounts/CreateAccount';
import AccountDetails from '../pages/Admin/Accounts/AccountDetails';

// Adicionar rotas protegidas para Super Admin
{
  path: '/admin',
  element: <AdminLayout />,
  children: [
    {
      path: 'accounts',
      element: <AccountsList />
    },
    {
      path: 'accounts/new',
      element: <CreateAccount />
    },
    {
      path: 'accounts/:id',
      element: <AccountDetails />
    }
  ]
}
```

#### 2.4. Adicionar Item no Menu (apenas para Super Admin)

**Arquivo**: `evo-ai-frontend-community-main/src/components/Sidebar/index.jsx`

```jsx
// Verificar se usuário é super_admin
const isSuperAdmin = user?.role?.key === 'super_admin';

// Adicionar item no menu
{isSuperAdmin && (
  <MenuItem
    icon={<BuildingIcon />}
    label="Gerenciar Empresas"
    to="/admin/accounts"
  />
)}
```

---

### Fase 3: Integração e Testes (1-2 dias)

#### 3.1. Testar Fluxo Completo

1. **Login como Super Admin**
   - Email: tonygomes058@gmail.com
   - Senha: To811205ny@

2. **Criar Nova Empresa**
   - Nome: "Empresa Teste"
   - Domínio: "teste.com"
   - Email: "suporte@teste.com"
   - Admin: "Admin Teste" / "admin@teste.com" / "senha123"

3. **Verificar Isolamento**
   - Fazer login como admin@teste.com
   - Verificar que só vê dados da "Empresa Teste"
   - Não deve ver dados da empresa padrão

4. **Testar Super Admin**
   - Fazer login como tonygomes058@gmail.com
   - Deve ver todas as empresas
   - Deve poder alternar entre empresas (via header X-Account-Id)

#### 3.2. Testes de Segurança

```bash
# Tentar acessar endpoint admin sem ser super_admin
curl -X GET http://localhost:3030/api/v1/admin/accounts \
  -H "Authorization: Bearer <token_account_admin>"
# Esperado: 403 Forbidden

# Tentar acessar dados de outra account
curl -X GET http://localhost:3030/api/v1/agents \
  -H "Authorization: Bearer <token_account_a>" \
  -H "X-Account-Id: <id_account_b>"
# Esperado: 403 Forbidden (se não tiver acesso)
```

---

## 📋 Checklist de Implementação

### Backend

- [ ] Criar role `super_admin` no seed
- [ ] Criar role `account_admin` no seed
- [ ] Atualizar usuário atual para super_admin
- [ ] Criar controller `Admin::AccountsController`
- [ ] Implementar endpoints CRUD de accounts
- [ ] Adicionar rotas `/api/v1/admin/accounts`
- [ ] Criar middleware `require_super_admin!`
- [ ] Implementar criação de admin junto com account
- [ ] Testar endpoints via Postman/curl

### Frontend

- [ ] Criar página `AccountsList`
- [ ] Criar página `CreateAccount`
- [ ] Criar página `AccountDetails`
- [ ] Adicionar rotas `/admin/accounts`
- [ ] Adicionar item no menu (apenas super_admin)
- [ ] Implementar chamadas à API
- [ ] Adicionar validações de formulário
- [ ] Testar fluxo completo no navegador

### Testes

- [ ] Testar criação de empresa
- [ ] Testar criação de admin
- [ ] Testar isolamento de dados
- [ ] Testar acesso super_admin
- [ ] Testar acesso negado para não-super_admin
- [ ] Testar alternância de accounts (X-Account-Id)

---

## 🎯 Resultado Esperado

Após implementação completa, você terá:

1. **Interface de Administração Global**
   - Listagem de todas as empresas
   - Criação de novas empresas
   - Criação de administradores por empresa
   - Visualização de estatísticas

2. **Hierarquia de Acesso**
   - **Super Admin**: Vê e gerencia todas as empresas
   - **Account Admin**: Gerencia apenas sua empresa
   - **Agent**: Acesso limitado (atendente)

3. **Isolamento de Dados**
   - Cada empresa vê apenas seus próprios dados
   - Super Admin pode alternar entre empresas
   - Segurança garantida por middleware e repository filters

---

## 📚 Próximos Passos

1. **Implementar Backend** (Fase 1)
2. **Implementar Frontend** (Fase 2)
3. **Testar e Validar** (Fase 3)
4. **Documentar** (criar guia de uso)
5. **Deploy** (aplicar em produção)

---

## 💡 Dicas de Implementação

### Para o Backend

1. Use `before_action :require_super_admin!` em todos os controllers admin
2. Sempre valide que o usuário tem acesso à account solicitada
3. Use transações para criar account + admin atomicamente
4. Implemente soft delete para accounts (status: 'inactive')

### Para o Frontend

1. Crie um hook `useAuth` para verificar role do usuário
2. Use React Context para gerenciar account atual
3. Implemente loading states em todos os formulários
4. Adicione confirmação antes de deletar accounts

### Para Testes

1. Crie fixtures com múltiplas accounts
2. Teste sempre com 2+ accounts diferentes
3. Verifique logs do backend para debug
4. Use Postman Collections para testes de API

---

**Tempo Estimado Total**: 6-9 dias  
**Prioridade**: Alta (necessário para multi-tenancy funcional)  
**Complexidade**: Média

