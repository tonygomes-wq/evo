# 🔧 Correção dos Serviços que Não Estão Iniciando

## Status Atual dos Serviços

✅ **Funcionando:**
- evo-auth: RUNNING
- evo-auth-sidekiq: RUNNING
- evo-bot-runtime: RUNNING
- evo-core: RUNNING
- evo-frontend: RUNNING
- evo-processor: RUNNING

❌ **Com Problemas:**
- evo-crm: BUILD OK mas falha no runtime
- evo-crm-sidekiq: BUILD FAILED

---

## 🔴 PROBLEMA 1: evo-crm-sidekiq - Caminho de Build Incorreto

### Erro Atual
```
/evo-crm-community-main/evo-ai-crm-community/docker: no such file or directory
```

### Causa
O caminho de build no Easypanel está com barra inicial (`/evo-ai-crm-community-main`) quando deveria ser sem barra (`evo-ai-crm-community-main`).

### ✅ SOLUÇÃO

1. **Acessar Easypanel:**
   - Projeto: `evogo`
   - Serviço: `evo-crm-sidekiq`

2. **Corrigir Caminho de Build:**
   - Clicar em **"Fonte"** (Source)
   - Seção **"Github"**
   - Campo **"Caminho de Build"** (Build Path)
   - **MUDAR DE:** `/evo-ai-crm-community-main`
   - **MUDAR PARA:** `evo-ai-crm-community-main` (SEM barra inicial)

3. **Corrigir Caminho do Dockerfile:**
   - Campo **"Caminho do Dockerfile"**
   - **DEVE SER:** `docker/Dockerfile`

4. **Salvar e Rebuild:**
   - Clicar em **"Salvar"**
   - Clicar em **"Rebuild"**

---

## 🔴 PROBLEMA 2: evo-crm - Senha do PostgreSQL Incorreta

### Erro Atual
```
PG::ConnectionBad: FATAL: password authentication failed for user "postgres"
```

### Causa
A senha do PostgreSQL nas variáveis de ambiente está incorreta.

### ✅ SOLUÇÃO

1. **Acessar Easypanel:**
   - Projeto: `evogo`
   - Serviço: `evo-crm`

2. **Corrigir Variáveis de Ambiente:**
   - Clicar em **"Ambiente"** (Environment)
   - Localizar: `POSTGRES_PASSWORD`
   - **MUDAR DE:** `355cbf3375d96724d0ff`
   - **MUDAR PARA:** `355cbf3375d96724de1f` (corrigir últimos 4 caracteres)

3. **Verificar Outras Variáveis do PostgreSQL:**
   ```env
   POSTGRES_HOST=evogo_postgres
   POSTGRES_PORT=5432
   POSTGRES_USERNAME=postgres
   POSTGRES_PASSWORD=355cbf3375d96724de1f
   POSTGRES_DATABASE=evo_community
   ```

4. **Salvar e Reiniciar:**
   - Clicar em **"Salvar"**
   - Clicar em **"Reiniciar"** (Restart)

---

## 🔴 PROBLEMA 3: evo-crm - Erro de Autenticação Redis

### Erro Atual
```
WRONGPASS invalid username-password pair
NOAUTH Authentication required
```

### Causa
A URL do Redis não está incluindo a senha corretamente.

### ✅ SOLUÇÃO

1. **Acessar Easypanel:**
   - Projeto: `evogo`
   - Serviço: `evo-crm`

2. **Corrigir REDIS_URL:**
   - Clicar em **"Ambiente"** (Environment)
   - Localizar: `REDIS_URL`
   - **DEVE SER:** `redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0`
   - Verificar que tem `:` antes da senha
   - Verificar que tem `@` depois da senha

3. **Salvar e Reiniciar:**
   - Clicar em **"Salvar"**
   - Clicar em **"Reiniciar"** (Restart)

---

## 🔴 PROBLEMA 4: evo-crm - Erro de Migração (Coluna Duplicada)

### Erro Atual
```
PG::DuplicateColumn: column "sentiment_offensive" already exists
```

### Causa
A migração `20251114150000` está tentando adicionar uma coluna que já existe no banco de dados.

### ✅ SOLUÇÃO

**Opção A: Marcar Migração como Executada (RECOMENDADO)**

1. **Acessar Console do evo-crm:**
   - No Easypanel, serviço `evo-crm`
   - Clicar em **"Console"** ou **"Terminal"**
   - Selecionar **"Bash"**

2. **Executar Comando:**
   ```bash
   bundle exec rails runner "ActiveRecord::Base.connection.execute(\"INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING\")"
   ```

3. **Reiniciar Serviço:**
   - Sair do console
   - Clicar em **"Reiniciar"**

**Opção B: Remover Coluna e Reexecutar Migração**

1. **Acessar Console do evo-crm:**
   ```bash
   bundle exec rails runner "ActiveRecord::Base.connection.execute(\"ALTER TABLE messages DROP COLUMN IF EXISTS sentiment_offensive\")"
   ```

2. **Executar Migrações:**
   ```bash
   bundle exec rails db:migrate
   ```

3. **Reiniciar Serviço**

---

## 🔴 PROBLEMA 5: evo-crm-sidekiq - Mesmas Correções

Após corrigir o caminho de build, aplicar as mesmas correções de variáveis de ambiente:

1. **Corrigir POSTGRES_PASSWORD:**
   - `355cbf3375d96724de1f`

2. **Corrigir REDIS_URL:**
   - `redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0`

3. **Salvar e Rebuild**

---

## 📋 Ordem de Execução das Correções

Execute nesta ordem para evitar problemas:

### 1️⃣ Corrigir evo-crm PRIMEIRO
```
1. Corrigir POSTGRES_PASSWORD
2. Corrigir REDIS_URL
3. Salvar e Reiniciar
4. Aguardar iniciar (verificar logs)
5. Se erro de migração, executar fix da migração
6. Reiniciar novamente
```

### 2️⃣ Corrigir evo-crm-sidekiq DEPOIS
```
1. Corrigir Caminho de Build (remover barra inicial)
2. Corrigir POSTGRES_PASSWORD
3. Corrigir REDIS_URL
4. Salvar e Rebuild
5. Aguardar build completar
6. Verificar se iniciou corretamente
```

---

## ✅ Verificação Final

Após aplicar todas as correções, verificar:

### 1. Verificar Logs do evo-crm
```
Deve mostrar:
- ✅ Conexão com PostgreSQL OK
- ✅ Conexão com Redis OK
- ✅ Migrações executadas
- ✅ Servidor iniciado na porta 3000
```

### 2. Verificar Logs do evo-crm-sidekiq
```
Deve mostrar:
- ✅ Build completado
- ✅ Sidekiq iniciado
- ✅ Conectado ao Redis
- ✅ Processando filas
```

### 3. Testar Health Check
```bash
curl https://api.macip.com.br/health/live
```

Deve retornar: `{"status":"ok"}`

### 4. Testar Login no Frontend
```
1. Acessar: https://evo.macip.com.br
2. Login: support@evo-auth-service-community.com
3. Senha: Password@123
```

---

## 🔍 Comandos de Diagnóstico

Se ainda houver problemas, usar estes comandos:

### Verificar Conexão PostgreSQL
```bash
# No console do evo-crm
bundle exec rails runner "puts ActiveRecord::Base.connection.execute('SELECT version()').first"
```

### Verificar Conexão Redis
```bash
# No console do evo-crm
bundle exec rails runner "puts Redis.new(url: ENV['REDIS_URL']).ping"
```

### Verificar Migrações Pendentes
```bash
# No console do evo-crm
bundle exec rails db:migrate:status
```

### Listar Todas as Migrações Executadas
```bash
# No console do evo-crm
bundle exec rails runner "puts ActiveRecord::Base.connection.execute('SELECT * FROM schema_migrations ORDER BY version').to_a"
```

---

## 📝 Resumo das Variáveis Corretas

### evo-crm e evo-crm-sidekiq

```env
# Database
POSTGRES_HOST=evogo_postgres
POSTGRES_PORT=5432
POSTGRES_USERNAME=postgres
POSTGRES_PASSWORD=355cbf3375d96724de1f
POSTGRES_DATABASE=evo_community

# Redis
REDIS_URL=redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0

# Secrets
SECRET_KEY_BASE=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
JWT_SECRET_KEY=+ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA==
EVOAI_CRM_API_TOKEN=22d16004-2706-4df5-a9e4-31dc35053816
BOT_RUNTIME_SECRET=6c042ef5122814fe0ca8224908957ba39a55dfd1f0c3ae1dd8c4e0a3f5623b50
ENCRYPTION_KEY=G5ceki9s9/Klo5rR0IKJONPx6mxHVeLASqR518klR7Q=

# URLs Internas
EVO_AUTH_SERVICE_URL=http://evo-auth:3001
EVO_AI_CORE_SERVICE_URL=http://evo-core:5555
BOT_RUNTIME_URL=http://evo-bot-runtime:8080
BOT_RUNTIME_POSTBACK_BASE_URL=http://evo-crm:3000

# URLs Públicas
BACKEND_URL=https://api.macip.com.br
FRONTEND_URL=https://evo.macip.com.br
CORS_ORIGINS=https://evo.macip.com.br,https://api.macip.com.br

# Rails
RAILS_ENV=production
RAILS_MAX_THREADS=5
RAILS_LOG_TO_STDOUT=true

# Features
DISABLE_TELEMETRY=true
ENABLE_ACCOUNT_SIGNUP=true
ENABLE_PUSH_RELAY_SERVER=true
ENABLE_INBOX_EVENTS=true
LOG_LEVEL=info
LOG_SIZE=500
FB_VERIFY_TOKEN=evolution
FACEBOOK_API_VERSION=v23.0
```

---

## 🎯 Configurações do Easypanel

### evo-crm
```
Nome: evo-crm
Porta: 3000
Domínio: api.macip.com.br
Repositório: evo-ai-crm-community-main
Caminho de Build: evo-ai-crm-community-main (SEM barra inicial)
Dockerfile: docker/Dockerfile
Health Check: /health/live (porta 3000)
```

### evo-crm-sidekiq
```
Nome: evo-crm-sidekiq
Porta: (nenhuma - worker)
Repositório: evo-ai-crm-community-main
Caminho de Build: evo-ai-crm-community-main (SEM barra inicial)
Dockerfile: docker/Dockerfile
Comando: bundle exec sidekiq -C config/sidekiq.yml
```

---

## ⚠️ IMPORTANTE

1. **Sempre corrigir evo-crm ANTES de evo-crm-sidekiq**
2. **Aguardar evo-crm estar 100% funcional antes de iniciar sidekiq**
3. **Verificar logs após cada mudança**
4. **Não fazer múltiplas mudanças ao mesmo tempo**
5. **Testar health check após cada correção**

---

## 📞 Suporte

Se após todas as correções ainda houver problemas:

1. Capturar logs completos do serviço com problema
2. Verificar se todas as variáveis estão exatamente como documentado
3. Testar conexões manualmente via console
4. Verificar se o banco de dados `evo_community` existe e tem as extensões habilitadas

---

**Última atualização:** 21/04/2026
**Status:** Aguardando aplicação das correções
