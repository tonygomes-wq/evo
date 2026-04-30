# 🔴 PROBLEMA CRÍTICO IDENTIFICADO - Arquivo .env Ausente

**Data:** 2026-04-30  
**Hora:** 01:50 BRT  
**Severidade:** 🔴 **CRÍTICA**

---

## 🔴 PROBLEMA RAIZ IDENTIFICADO

O arquivo **`.env` NÃO EXISTE** no diretório do projeto!

Isso explica **TODOS** os problemas:
- evo-auth em loop de restart
- RAILS_ENV=development (deveria ser production)
- Variáveis vazias (SECRET_KEY_BASE, JWT_SECRET_KEY, etc.)
- Impossibilidade de login

---

## 📋 Evidências

### 1. Arquivo .env Ausente
```powershell
PS> Test-Path .env
False

PS> Arquivo .env NÃO existe
```

### 2. Variáveis Vazias no Docker Compose
```
time="2026-04-29T21:48:32-03:00" level=warning msg="The \"BACKEND_URL\" variable is not set. Defaulting to a blank string."
time="2026-04-29T21:48:32-03:00" level=warning msg="The \"REDIS_PASSWORD\" variable is not set. Defaulting to a blank string."
time="2026-04-29T21:48:32-03:00" level=warning msg="The \"POSTGRES_PASSWORD\" variable is not set. Defaulting to a blank string."
time="2026-04-29T21:48:32-03:00" level=warning msg="The \"SECRET_KEY_BASE\" variable is not set. Defaulting to a blank string."
time="2026-04-29T21:48:32-03:00" level=warning msg="The \"JWT_SECRET_KEY\" variable is not set. Defaulting to a blank string."
time="2026-04-29T21:48:32-03:00" level=warning msg="The \"DOORKEEPER_JWT_SECRET_KEY\" variable is not set. Defaulting to a blank string."
time="2026-04-29T21:48:32-03:00" level=warning msg="The \"ENCRYPTION_KEY\" variable is not set. Defaulting to a blank string."
```

### 3. RAILS_ENV Incorreto
```
RAILS_ENV=development  (deveria ser production)
```

---

## ✅ SOLUÇÃO

### Passo 1: Criar Arquivo .env

Você precisa criar um arquivo `.env` na raiz do projeto com todas as variáveis necessárias.

**Exemplo de .env mínimo:**

```env
# Ambiente
RAILS_ENV=production

# URLs
BACKEND_URL=http://localhost:3030
FRONTEND_URL=http://localhost:5173
CORS_ORIGINS=http://localhost:5173,http://localhost:3000

# Banco de Dados
POSTGRES_DATABASE=evo_community
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=SUA_SENHA_POSTGRES_AQUI

# Redis
REDIS_PASSWORD=SUA_SENHA_REDIS_AQUI

# Chaves de Segurança (gerar novas)
SECRET_KEY_BASE=GERAR_CHAVE_LONGA_AQUI
JWT_SECRET_KEY=GERAR_CHAVE_LONGA_AQUI
DOORKEEPER_JWT_SECRET_KEY=GERAR_CHAVE_LONGA_AQUI
ENCRYPTION_KEY=GERAR_CHAVE_32_BYTES_AQUI

# API Token
EVOAI_CRM_API_TOKEN=GERAR_TOKEN_AQUI
```

### Passo 2: Gerar Chaves de Segurança

```powershell
# Gerar SECRET_KEY_BASE (128 caracteres hex)
$secret = -join ((48..57) + (97..102) | Get-Random -Count 128 | ForEach-Object {[char]$_})
Write-Host "SECRET_KEY_BASE=$secret"

# Gerar JWT_SECRET_KEY (128 caracteres hex)
$jwt = -join ((48..57) + (97..102) | Get-Random -Count 128 | ForEach-Object {[char]$_})
Write-Host "JWT_SECRET_KEY=$jwt"

# Gerar DOORKEEPER_JWT_SECRET_KEY (128 caracteres hex)
$doorkeeper = -join ((48..57) + (97..102) | Get-Random -Count 128 | ForEach-Object {[char]$_})
Write-Host "DOORKEEPER_JWT_SECRET_KEY=$doorkeeper"

# Gerar ENCRYPTION_KEY (32 bytes = 64 caracteres hex)
$encryption = -join ((48..57) + (97..102) | Get-Random -Count 64 | ForEach-Object {[char]$_})
Write-Host "ENCRYPTION_KEY=$encryption"

# Gerar EVOAI_CRM_API_TOKEN
$apitoken = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 64 | ForEach-Object {[char]$_})
Write-Host "EVOAI_CRM_API_TOKEN=$apitoken"
```

### Passo 3: Verificar Senhas Existentes

```powershell
# Verificar senha do PostgreSQL
docker exec evo-crm-community-main-postgres-1 printenv | Select-String "POSTGRES_PASSWORD"

# Verificar senha do Redis
docker exec evo-crm-community-main-redis-1 printenv | Select-String "REDIS_PASSWORD"
```

### Passo 4: Reiniciar Sistema

```powershell
# Parar todos os containers
docker-compose -f docker-compose.dokploy.yaml down

# Subir novamente (vai carregar o .env)
docker-compose -f docker-compose.dokploy.yaml up -d

# Acompanhar logs
docker logs -f evo-crm-community-main-evo-auth-1
```

---

## 📝 Arquivo .env.example

Se houver um arquivo `.env.example` no projeto, você pode copiá-lo:

```powershell
# Verificar se existe .env.example
if (Test-Path .env.example) {
    Copy-Item .env.example .env
    Write-Host "Arquivo .env criado a partir do .env.example"
    Write-Host "IMPORTANTE: Edite o .env e preencha as senhas e chaves!"
} else {
    Write-Host ".env.example não encontrado"
}
```

---

## 🎯 Por Que Isso Aconteceu?

1. **Arquivo .env não foi commitado** (correto, por segurança)
2. **Arquivo .env não foi criado** após clonar o repositório
3. **Docker Compose depende do .env** para variáveis de ambiente
4. **Sem .env, todas as variáveis ficam vazias**
5. **Serviços não conseguem iniciar** sem as configurações

---

## ✅ Checklist de Configuração

Após criar o `.env`, verifique:

- [ ] RAILS_ENV=production
- [ ] POSTGRES_PASSWORD definida (mesma do container postgres)
- [ ] REDIS_PASSWORD definida (mesma do container redis)
- [ ] SECRET_KEY_BASE gerada (128 caracteres)
- [ ] JWT_SECRET_KEY gerada (128 caracteres)
- [ ] DOORKEEPER_JWT_SECRET_KEY gerada (128 caracteres)
- [ ] ENCRYPTION_KEY gerada (64 caracteres)
- [ ] BACKEND_URL definida
- [ ] FRONTEND_URL definida
- [ ] CORS_ORIGINS definida

---

## 🔍 Como Verificar se Funcionou

```powershell
# 1. Verificar se .env existe
Test-Path .env

# 2. Ver primeiras linhas do .env (sem mostrar senhas)
Get-Content .env | Select-Object -First 5

# 3. Subir containers
docker-compose -f docker-compose.dokploy.yaml up -d

# 4. Verificar se evo-auth iniciou
docker logs evo-crm-community-main-evo-auth-1 --tail 50

# 5. Procurar por "Listening on"
docker logs evo-crm-community-main-evo-auth-1 2>&1 | Select-String "Listening"

# 6. Testar login
curl http://localhost:3001/health
```

---

## 📊 Status Atual

### O que Está Funcionando ✅
- ✅ postgres (com senha hardcoded no container)
- ✅ redis (com senha hardcoded no container)
- ✅ evo-processor (não depende muito do .env)
- ✅ evo-crm (tem .env próprio ou variáveis hardcoded)
- ✅ evo-core (tem .env próprio ou variáveis hardcoded)

### O que NÃO Está Funcionando 🔴
- 🔴 evo-auth (depende 100% do .env)
- 🔴 evo-auth-sidekiq (depende do .env)
- 🔴 Login no sistema (depende do evo-auth)

---

## 🎉 Após Criar o .env

Com o arquivo `.env` corretamente configurado:

1. ✅ evo-auth vai iniciar em modo **production**
2. ✅ Todas as variáveis estarão definidas
3. ✅ Servidor Rails vai iniciar corretamente
4. ✅ Login vai funcionar
5. ✅ Credenciais **tonygomes058@gmail.com** / **To811205ny@** vão funcionar

---

## 📞 Comandos Úteis

```powershell
# Criar .env vazio
New-Item -Path .env -ItemType File

# Editar .env
notepad .env

# Verificar variáveis carregadas
docker-compose -f docker-compose.dokploy.yaml config | Select-String "RAILS_ENV"

# Testar sem subir containers
docker-compose -f docker-compose.dokploy.yaml config
```

---

## ✅ RESUMO

**Problema Raiz:** Arquivo `.env` ausente  
**Impacto:** evo-auth não consegue iniciar  
**Solução:** Criar arquivo `.env` com todas as variáveis  
**Tempo Estimado:** 10-15 minutos  
**Prioridade:** 🔴 **CRÍTICA**

---

**Responsável:** Assistente AI  
**Data:** 2026-04-30 01:50 BRT  
**Status:** 🔴 **BLOQUEADOR IDENTIFICADO - REQUER AÇÃO DO USUÁRIO**
