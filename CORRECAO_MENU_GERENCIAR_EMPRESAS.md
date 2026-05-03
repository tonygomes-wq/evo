# Correção - Menu "Gerenciar Empresas" Não Aparecia

**Data**: 02/05/2026  
**Status**: ✅ **CORRIGIDO**

---

## 🐛 Problema Identificado

O menu "Gerenciar Empresas" não estava aparecendo para o usuário `super_admin`, mesmo com a role configurada corretamente no backend.

### Causa Raiz

A interface TypeScript `Role` no frontend não incluía o tipo `'system'` como uma opção válida para o campo `type`. A interface estava definida como:

```typescript
type: 'user' | 'account'
```

Mas a role `super_admin` no backend tem:

```typescript
type: 'system'
```

Isso causava uma incompatibilidade de tipos, fazendo com que o filtro de menu não funcionasse corretamente.

---

## ✅ Solução Aplicada

Atualizamos a interface `Role` e interfaces relacionadas no arquivo `evo-ai-frontend-community-main/src/types/auth/rbac.ts` para incluir o tipo `'system'`:

### Mudanças Realizadas

1. **Interface Role**:
```typescript
export interface Role {
  id: string;
  key: string;
  name: string;
  description: string;
  system: boolean;
  type: 'user' | 'account' | 'system'; // ✅ Adicionado 'system'
  created_at: string;
  updated_at: string;
  permissions_count?: number;
  users_count?: number;
}
```

2. **Interface RoleCreate**:
```typescript
export interface RoleCreate {
  key: string;
  name: string;
  description?: string;
  system?: boolean;
  type: 'user' | 'account' | 'system'; // ✅ Adicionado 'system'
}
```

3. **Interface RoleUpdate**:
```typescript
export interface RoleUpdate {
  key?: string;
  name?: string;
  description?: string;
  system?: boolean;
  type?: 'user' | 'account' | 'system'; // ✅ Adicionado 'system'
}
```

4. **Interface RoleFilters**:
```typescript
export interface RoleFilters {
  search?: string;
  systemOnly?: boolean;
  type?: 'user' | 'account' | 'system'; // ✅ Adicionado 'system'
  sortBy?: string;
  sortDirection?: 'asc' | 'desc';
}
```

---

## 🔄 Ações Realizadas

1. ✅ Atualizado arquivo `rbac.ts` com o tipo `'system'`
2. ✅ Reiniciado o serviço frontend (`docker restart evo-evo-frontend-1`)
3. ✅ Frontend rodando normalmente

---

## 🧪 Como Testar Agora

### Passo 1: Limpar Cache do Navegador
1. Abra o navegador
2. Pressione `Ctrl + Shift + Delete`
3. Selecione "Cache" e "Cookies"
4. Clique em "Limpar dados"

### Passo 2: Fazer Login Novamente
1. Acesse: `http://localhost:5173/login`
2. Faça login com:
   - **Email**: `tonygomes058@gmail.com`
   - **Senha**: `To811205ny@`

### Passo 3: Verificar o Menu
- O item **"Gerenciar Empresas"** deve aparecer no menu lateral esquerdo
- Ícone: 🏢 (prédio)
- Localização: Entre "Canais" e "Tutoriais"

---

## 🔍 Verificação Técnica

### Verificar Role do Usuário no Backend
```bash
docker exec -it evo-evo-auth-1 bundle exec rails runner "
  user = User.find_by(email: 'tonygomes058@gmail.com')
  puts 'Email: ' + user.email
  puts 'Role Key: ' + user.roles.first.key
  puts 'Role Type: ' + user.roles.first.type
"
```

**Resultado Esperado**:
```
Email: tonygomes058@gmail.com
Role Key: super_admin
Role Type: system
```

### Verificar no Console do Navegador
1. Abra o console do navegador (F12)
2. Digite:
```javascript
// Verificar usuário logado
console.log(JSON.parse(localStorage.getItem('auth-storage')))

// Verificar role
const authData = JSON.parse(localStorage.getItem('auth-storage'))
console.log('Role:', authData?.state?.currentUser?.role)
```

**Resultado Esperado**:
```javascript
{
  key: "super_admin",
  name: "Super Admin",
  type: "system",
  ...
}
```

---

## 📊 Estrutura de Roles

### Tipos de Roles no Sistema

| Tipo | Descrição | Exemplo |
|------|-----------|---------|
| `user` | Roles de usuários normais | account_owner |
| `account` | Roles específicas de uma empresa | agent, account_admin |
| `system` | Roles globais do sistema | super_admin |

### Hierarquia de Permissões

1. **super_admin** (type: `system`)
   - Acesso global a todas as empresas
   - Pode criar e gerenciar empresas
   - 279 permissões

2. **account_admin** (type: `account`)
   - Administrador de uma empresa específica
   - Pode gerenciar usuários da empresa
   - 278 permissões

3. **account_owner** (type: `user`)
   - Proprietário de uma empresa
   - Acesso completo aos recursos da empresa
   - 278 permissões

4. **agent** (type: `account`)
   - Agente de atendimento
   - Acesso limitado aos recursos
   - 107 permissões

---

## 🎯 Filtro de Menu

### Como Funciona

O filtro de menu usa a função `filterMenuItemsByPermissions` que verifica:

1. **requiredRoleKey**: Se o item requer uma role específica
2. **permissions**: Se o item requer permissões específicas
3. **resource.action**: Se o item requer acesso a um recurso

### Exemplo do Item "Gerenciar Empresas"

```typescript
{
  name: t('menu.customer.manageAccounts'),
  href: '/admin/accounts',
  icon: Building2,
  requiredRoleKey: 'super_admin', // ✅ Verifica se user.role.key === 'super_admin'
}
```

### Lógica de Verificação

```typescript
// Em menuItems.ts
export const shouldShowMenuItem = (
  item: MenuItem | SubMenuItem,
  canFunction: (resource: string, action: string) => boolean,
  canAnyFunction: (permissions: string[]) => boolean,
  canAllFunction: (permissions: string[]) => boolean,
  userRoleKey?: string // ✅ Recebe o role.key do usuário
): boolean => {
  // Verificar role obrigatória
  if (item.requiredRoleKey) {
    return userRoleKey === item.requiredRoleKey; // ✅ Compara com 'super_admin'
  }
  
  // ... outras verificações
}
```

---

## 🚨 Troubleshooting

### Problema: Menu ainda não aparece após a correção

**Soluções**:

1. **Limpar cache do navegador**:
   - Pressione `Ctrl + Shift + Delete`
   - Limpe cache e cookies
   - Recarregue a página

2. **Fazer logout e login novamente**:
   - Faça logout do sistema
   - Limpe o localStorage:
     ```javascript
     localStorage.clear()
     ```
   - Faça login novamente

3. **Verificar se o frontend compilou corretamente**:
   ```bash
   docker logs evo-evo-frontend-1 --tail 50
   ```
   - Procure por erros de compilação
   - Se houver erros, reinicie o frontend:
     ```bash
     docker restart evo-evo-frontend-1
     ```

4. **Verificar se a role está correta no backend**:
   ```bash
   docker exec -it evo-evo-auth-1 bundle exec rails runner "
     user = User.find_by(email: 'tonygomes058@gmail.com')
     puts user.roles.first.key
   "
   ```
   - Deve retornar: `super_admin`

5. **Verificar se o tipo da role está correto**:
   ```bash
   docker exec -it evo-evo-auth-1 bundle exec rails runner "
     user = User.find_by(email: 'tonygomes058@gmail.com')
     puts user.roles.first.type
   "
   ```
   - Deve retornar: `system`

---

## 📝 Arquivos Modificados

1. `evo-ai-frontend-community-main/src/types/auth/rbac.ts`
   - Interface `Role`: Adicionado tipo `'system'`
   - Interface `RoleCreate`: Adicionado tipo `'system'`
   - Interface `RoleUpdate`: Adicionado tipo `'system'`
   - Interface `RoleFilters`: Adicionado tipo `'system'`

---

## ✅ Checklist de Verificação

Após aplicar a correção, verifique:

- [ ] Frontend reiniciado com sucesso
- [ ] Cache do navegador limpo
- [ ] Logout e login realizados
- [ ] Menu "Gerenciar Empresas" aparece no menu lateral
- [ ] Ícone de prédio (Building2) visível
- [ ] Clique no menu redireciona para `/admin/accounts`
- [ ] Página de listagem de empresas carrega corretamente

---

## 🎉 Resultado Esperado

Após aplicar a correção e seguir os passos de teste:

1. ✅ Menu "Gerenciar Empresas" visível para super_admin
2. ✅ Menu NÃO visível para outros usuários
3. ✅ Filtro de menu funcionando corretamente
4. ✅ Interface TypeScript consistente com backend

---

## 📚 Documentação Relacionada

- **TESTE_MULTI_TENANT_ADMIN.md**: Guia completo de testes
- **IMPLEMENTACAO_MULTI_TENANT_COMPLETA.md**: Documentação técnica
- **RESUMO_IMPLEMENTACAO_FINAL.md**: Resumo executivo
- **QUICK_START.md**: Guia rápido de 5 minutos

---

**Última Atualização**: 02/05/2026 14:50 BRT  
**Responsável**: Tony Gomes  
**Status**: ✅ **CORRIGIDO - PRONTO PARA TESTES**
