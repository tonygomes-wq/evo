# 🔧 Comandos Corretos - EasyPanel

**Problema:** Você está no terminal do servidor host, não dentro do container

---

## 🎯 Como Acessar o Terminal Correto no EasyPanel

### Método 1: Via Interface do EasyPanel (Recomendado)

1. **Abrir o EasyPanel** no navegador
2. Ir em **Projects** → **evogo**
3. Clicar no serviço **evo-auth**
4. Clicar no ícone de **Terminal** (console/shell)
5. Aguardar terminal abrir
6. Executar os comandos

### Método 2: Via Docker no Servidor

Se preferir usar SSH no servidor:

```bash
# Listar containers rodando
docker ps | grep evo

# Entrar no container do Auth
docker exec -it <CONTAINER_ID_DO_EVO_AUTH> bash

# OU pelo nome (se souber)
docker exec -it evo-auth bash
```

---

## 📋 Comandos Corretos por Serviço

### 1️⃣ Descobrir Email do Usuário (Auth Service)

**No terminal do container evo-auth:**

```bash
# Comando simples
bundle exec rails runner "puts User.first&.email || 'Nenhum usuário'"
```

**OU via Rails console:**

```bash
# Entrar no console
bundle exec rails console

# Listar usuários
User.all.each { |u| puts "Email: #{u.email}, Nome: #{u.name}" }

# Sair
exit
```

---

### 2️⃣ Criar Usuário se Não Existir (Auth Service)

**No terminal do container evo-auth:**

```bash
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
  UserRole.assign_role_to_user(user, role) if role
  puts 'Usuário criado: admin@macip.com.br / Admin123!'
else
  puts 'Já existe usuário: ' + User.first.email
end
"
```

---

### 3️⃣ Resetar Senha de Usuário (Auth Service)

**No terminal do container evo-auth:**

```bash
bundle exec rails runner "
user = User.find_by(email: 'support@evo-auth-service-community.com')
if user
  user.update!(
    password: 'NovaSenha123!',
    password_confirmation: 'NovaSenha123!',
    confirmed_at: Time.current
  )
  puts 'Senha resetada para: NovaSenha123!'
else
  puts 'Usuário não encontrado'
end
"
```

---

### 4️⃣ Verificar Banco de Dados (PostgreSQL)

**No terminal do container evogo_postgres:**

```bash
# Conectar no banco
psql -U postgres -d postgres

# Listar usuários
SELECT email, name, confirmed_at FROM users;

# Contar usuários
SELECT COUNT(*) FROM users;

# Sair
\q
```

---

## 🚀 Passo a Passo Completo (Via EasyPanel UI)

### Descobrir Credenciais:

1. **Abrir EasyPanel** no navegador
2. Ir em **evogo** → **evo-auth**
3. Clicar no ícone **Terminal** (console)
4. Aguardar terminal abrir
5. Executar:
   ```bash
   bundle exec rails runner "User.all.each { |u| puts u.email }"
   ```
6. Anotar o email que aparecer

### Se Não Houver Usuários:

1. No mesmo terminal do **evo-auth**
2. Executar:
   ```bash
   bundle exec rails db:seed
   ```
3. Depois executar:
   ```bash
   bundle exec rails runner "
   user = User.create!(
     name: 'Admin',
     email: 'admin@macip.com.br',
     password: 'Admin123!',
     password_confirmation: 'Admin123!',
     provider: 'email',
     uid: 'admin@macip.com.br',
     confirmed_at: Time.current,
     type: 'User'
   )
   role = Role.find_by(key: 'account_owner')
   UserRole.assign_role_to_user(user, role) if role
   puts 'Criado!'
   "
   ```

### Fazer Login:

1. Acessar: https://evogo-evo-frontend.kub3.to.easypanel.host/login
2. Usar:
   - Email: `admin@macip.com.br`
   - Senha: `Admin123!`

---

## 🔍 Alternativa: Via Docker no Servidor

Se você tem acesso SSH ao servidor:

### 1. Listar Containers

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 2. Entrar no Container do Auth

```bash
# Encontrar o ID ou nome do container
docker ps | grep auth

# Entrar no container (substitua CONTAINER_ID)
docker exec -it CONTAINER_ID bash

# OU se souber o nome exato
docker exec -it evogo-evo-auth bash
```

### 3. Executar Comandos Rails

```bash
# Dentro do container
bundle exec rails runner "puts User.first&.email"
```

---

## 📊 Resumo Visual

```
┌─────────────────────────────────────────┐
│  Você está aqui (servidor host)        │
│  root@server:/#                         │
└─────────────────┬───────────────────────┘
                  │
                  │ Precisa entrar no container
                  ↓
┌─────────────────────────────────────────┐
│  Container evo-auth                     │
│  /app#                                  │
│                                         │
│  ✅ bundle exec rails ...               │
│  ✅ Comandos Rails funcionam aqui      │
└─────────────────────────────────────────┘
```

---

## 🎯 Solução Mais Simples

### Via EasyPanel UI (SEM SSH):

1. **Abrir EasyPanel** no navegador
2. **evogo** → **evo-auth** → **Terminal** (ícone de console)
3. Executar:
   ```bash
   bundle exec rails runner "puts User.count > 0 ? User.first.email : 'Nenhum usuário'"
   ```

**Se retornar um email:**
- Tente fazer login com esse email
- Senha padrão: `Password@123`

**Se retornar "Nenhum usuário":**
- Execute o comando de criar usuário (acima)
- Use: `admin@macip.com.br` / `Admin123!`

---

## ⚠️ Importante

**NÃO execute comandos Rails no servidor host!**

Você precisa estar **DENTRO do container** para:
- ✅ `bundle exec rails ...`
- ✅ `psql ...` (no container do PostgreSQL)

**No servidor host você pode:**
- ✅ `docker ps` (listar containers)
- ✅ `docker exec -it ...` (entrar em containers)
- ✅ `docker logs ...` (ver logs)

---

## 📞 Próximos Passos

1. ✅ **Abrir terminal do evo-auth** via EasyPanel UI
2. ✅ **Executar comando** para ver usuários
3. ✅ **Anotar email** que aparecer
4. ✅ **Tentar login** com esse email
5. ✅ **Resetar senha** se necessário

---

**Status:** 🔧 Aguardando acesso ao terminal correto  
**Próximo passo:** Abrir terminal do evo-auth via EasyPanel UI

