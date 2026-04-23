# 🔐 Credenciais de Login - EVO CRM

**Situação:** Frontend está funcionando e mostrando tela de login

---

## 🎯 Credenciais Padrão (Documentação)

Segundo a documentação do projeto, as credenciais padrão são:

```
Email: support@evo-auth-service-community.com
Senha: Password@123
```

**⚠️ IMPORTANTE:** Estas credenciais só funcionam se o seed foi executado E criou este usuário específico.

---

## 🔍 Como Descobrir o Usuário Real

Como você está vendo a tela de login (não a tela de setup), significa que **já existe pelo menos 1 usuário** no banco de dados.

### Opção 1: Verificar no PostgreSQL (Recomendado)

**No EasyPanel:**

1. Ir no serviço **evogo_postgres** (ou o nome do seu PostgreSQL)
2. Abrir **Terminal** ou **Console**
3. Executar:

```bash
# Conectar no banco
psql -U postgres -d postgres

# Listar todos os usuários
SELECT id, name, email, created_at, confirmed_at 
FROM users 
ORDER BY created_at ASC;
```

**Isso vai mostrar:**
- Email do(s) usuário(s)
- Nome
- Data de criação
- Se está confirmado

### Opção 2: Via Rails Console (Auth Service)

**No EasyPanel:**

1. Ir no serviço **evo-auth**
2. Abrir **Terminal**
3. Executar:

```bash
# Entrar no Rails console
bundle exec rails console

# Listar usuários
User.all.each do |u|
  puts "Email: #{u.email}"
  puts "Nome: #{u.name}"
  puts "Criado em: #{u.created_at}"
  puts "Confirmado: #{u.confirmed_at.present? ? 'Sim' : 'Não'}"
  puts "---"
end
```

---

## 🔧 Soluções por Cenário

### Cenário 1: Usuário Padrão Existe

Se encontrar o usuário `support@evo-auth-service-community.com`:

```
Email: support@evo-auth-service-community.com
Senha: Password@123
```

**Se não funcionar:**
- A senha pode ter sido alterada
- O usuário pode não estar confirmado

### Cenário 2: Outro Usuário Existe

Se encontrar outro email (ex: `admin@exemplo.com`):
- Você ou alguém já fez o setup
- Use o email encontrado
- A senha é a que foi definida no setup

### Cenário 3: Nenhum Usuário Existe

Se não houver usuários no banco:
- O seed não foi executado corretamente
- Precisa executar o seed manualmente

---

## 🚀 Executar Seed Manualmente

Se não houver usuários, execute o seed:

### No Auth Service:

```bash
# No terminal do evo-auth
bundle exec rails db:seed
```

**Isso vai:**
1. Criar roles e permissões
2. Configurar account config
3. **NÃO cria usuário** (precisa usar setup wizard)

### Criar Usuário Manualmente:

Se o seed não criar usuário, você pode criar via console:

```bash
# No Rails console do evo-auth
bundle exec rails console

# Criar usuário
User.create!(
  name: 'Admin',
  email: 'admin@macip.com.br',
  password: 'SuaSenhaSegura123!',
  password_confirmation: 'SuaSenhaSegura123!',
  provider: 'email',
  uid: 'admin@macip.com.br',
  availability: :online,
  mfa_method: :disabled,
  confirmed_at: Time.current,
  type: 'User'
)

# Atribuir role de owner
user = User.find_by(email: 'admin@macip.com.br')
role = Role.find_by(key: 'account_owner')
UserRole.assign_role_to_user(user, role)
```

---

## 🔑 Resetar Senha de Usuário Existente

Se você sabe o email mas esqueceu a senha:

```bash
# No Rails console do evo-auth
bundle exec rails console

# Resetar senha
user = User.find_by(email: 'support@evo-auth-service-community.com')
user.update!(
  password: 'NovaSenha123!',
  password_confirmation: 'NovaSenha123!'
)

# Confirmar usuário (se não estiver confirmado)
user.update!(confirmed_at: Time.current)
```

---

## 📋 Checklist de Verificação

### 1. Verificar se há usuários no banco
```sql
SELECT COUNT(*) FROM users;
```

### 2. Se houver usuários, listar emails
```sql
SELECT email, name, confirmed_at FROM users;
```

### 3. Tentar login com credenciais padrão
```
Email: support@evo-auth-service-community.com
Senha: Password@123
```

### 4. Se não funcionar, resetar senha
```ruby
user = User.first
user.update!(password: 'NovaSenha123!', password_confirmation: 'NovaSenha123!')
```

### 5. Confirmar usuário se necessário
```ruby
user.update!(confirmed_at: Time.current)
```

---

## 🎯 Comando Rápido (Copiar e Colar)

**Para descobrir o email do primeiro usuário:**

```bash
# No terminal do evo-auth
bundle exec rails runner "puts User.first&.email || 'Nenhum usuário encontrado'"
```

**Para criar usuário se não existir:**

```bash
# No terminal do evo-auth
bundle exec rails runner "
if User.count == 0
  user = User.create!(
    name: 'Admin',
    email: 'admin@macip.com.br',
    password: 'Admin123!',
    password_confirmation: 'Admin123!',
    provider: 'email',
    uid: 'admin@macip.com.br',
    availability: :online,
    mfa_method: :disabled,
    confirmed_at: Time.current,
    type: 'User'
  )
  role = Role.find_by(key: 'account_owner')
  UserRole.assign_role_to_user(user, role)
  puts 'Usuário criado: admin@macip.com.br / Admin123!'
else
  puts 'Já existe usuário: ' + User.first.email
end
"
```

---

## 🆘 Troubleshooting

### Erro: "Role not found"

Execute o seed primeiro:
```bash
bundle exec rails db:seed
```

### Erro: "Email has already been taken"

O usuário já existe. Liste os usuários:
```bash
bundle exec rails runner "User.all.each { |u| puts u.email }"
```

### Erro: "Password is too short"

A senha precisa ter pelo menos 8 caracteres e incluir:
- Letra maiúscula
- Letra minúscula
- Número
- Caractere especial (opcional)

---

## 📞 Próximos Passos

1. ✅ **Descobrir email do usuário** (via PostgreSQL ou Rails console)
2. ✅ **Tentar login** com credenciais padrão
3. ✅ **Resetar senha** se necessário
4. ✅ **Criar usuário** se não existir
5. ✅ **Fazer login** e acessar dashboard

---

**Status:** 🔍 Aguardando verificação do banco de dados  
**Próximo passo:** Executar comando SQL ou Rails console para descobrir o email

