# Evo CRM — Guia de Desenvolvimento

## Pré-requisitos

| Ferramenta | Versão mínima | Observação |
|------------|---------------|------------|
| Docker | 24+ | Obrigatório |
| Docker Compose | v2.x | Obrigatório |
| Git | 2.30+ | Com suporte a submodules |
| Go | 1.24.4 | Apenas para evo-core em dev local |
| Ruby | 3.4 | Apenas para evo-auth/evo-crm em dev local |
| Python | 3.10+ | Apenas para evo-processor em dev local |
| Node.js | 18+ | Apenas para evo-frontend em dev local |

---

## Setup Rápido (via Docker)

```bash
# 1. Clonar monorepo com submodules
git clone --recurse-submodules git@github.com:EvolutionAPI/evo-crm-community.git
cd evo-crm-community

# 2. Copiar e configurar variáveis de ambiente
cp _env.dokploy.example .env
# Editar .env — mínimo necessário para dev:
# POSTGRES_PASSWORD, REDIS_PASSWORD, SECRET_KEY_BASE,
# JWT_SECRET_KEY, ENCRYPTION_KEY, DOORKEEPER_JWT_SECRET_KEY

# 3. Subir infraestrutura + serviços
docker-compose -f docker-compose.dokploy.yaml up -d

# 4. Verificar saúde dos serviços
docker-compose -f docker-compose.dokploy.yaml ps
```

**Ordem de inicialização automática:**
1. `postgres` + `redis` (infraestrutura)
2. `evo_auth_init` (prepara banco auth + seed)
3. `evo-auth` (serviço auth)
4. `evo_crm_init` (prepara banco CRM + seed)
5. `evo-core` (core service Go)
6. `evo_processor_init` (aguarda tabelas evo-core + migra)
7. `evo-processor` + `evo-bot-runtime`
8. `evo-gateway` + `evo-frontend`

---

## Desenvolvimento Local — evo-core (Go)

```bash
cd evo-ai-core-service-community-main

# Instalar dependências
make install
# ou: go mod download

# Configurar .env local
cp .env.example .env
# Editar: DB_HOST, EVO_AUTH_BASE_URL, etc.

# Setup banco de dados
make db-setup       # Cria banco + aplica migrações

# Rodar em modo desenvolvimento (hot reload)
make dev

# Compilar binário de produção
make build

# Rodar binário compilado
make run
```

### Comandos úteis (evo-core)

```bash
make help              # Lista todos os comandos disponíveis
make test              # Executar testes
make lint              # Executar linter (golangci-lint)
make migrate-up        # Aplicar migrações pendentes
make migrate-down      # Reverter última migração
make migrate-create NAME=add_account_id  # Criar nova migração
make db-reset          # ⚠️ Resetar banco completo
```

---

## Desenvolvimento Local — evo-auth / evo-crm (Ruby/Rails)

```bash
cd evo-auth-service-community  # ou evo-ai-crm-community

# Instalar dependências
bundle install

# Configurar banco
bundle exec rails db:prepare

# Seed inicial
bundle exec rails db:seed

# Rodar servidor
bundle exec rails s -p 3001    # auth
bundle exec rails s -p 3000    # crm

# Rodar workers Sidekiq
bundle exec sidekiq
```

---

## Desenvolvimento Local — evo-processor (Python)

```bash
cd evo-ai-processor-community-main

# Criar virtualenv
python -m venv venv
source venv/bin/activate  # Linux/Mac
.\venv\Scripts\activate   # Windows

# Instalar dependências
pip install -r requirements.txt

# Migrações
alembic upgrade head

# Seeders
python -m scripts.run_seeders

# Rodar servidor
uvicorn app.main:app --reload --port 8000
```

---

## Desenvolvimento Local — evo-frontend (React/Vite)

```bash
cd evo-ai-frontend-community-main

# Instalar dependências
npm install

# Configurar variáveis
cp .env.example .env.local
# VITE_API_URL=http://localhost:3030

# Rodar dev server
npm run dev

# Build de produção
npm run build
```

---

## Variáveis de Ambiente

### Variáveis Obrigatórias

```env
# Banco de dados
POSTGRES_PASSWORD=<senha_forte>
POSTGRES_DATABASE=evo_community
POSTGRES_USERNAME=postgres

# Redis
REDIS_PASSWORD=<senha_forte>

# Secrets de segurança (gerar com: openssl rand -base64 48)
SECRET_KEY_BASE=<64+ chars>
JWT_SECRET_KEY=<64+ chars>
DOORKEEPER_JWT_SECRET_KEY=<64+ chars>

# Criptografia Fernet (gerar: python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")
ENCRYPTION_KEY=<fernet_key>

# Token de integração CRM→Core
EVOAI_CRM_API_TOKEN=<token>

# URLs públicas
BACKEND_URL=https://api.seudominio.com
FRONTEND_URL=https://app.seudominio.com
CORS_ORIGINS=https://app.seudominio.com
```

### Variáveis Opcionais (evo-core)

```env
# Rate limiting
RATE_LIMIT_GLOBAL_RPS=1000
RATE_LIMIT_GLOBAL_BURST=50
RATE_LIMIT_CLIENT_RPS=100
RATE_LIMIT_CLIENT_BURST=10

# Observabilidade
OTEL_TRACES_ENABLED=false
OTEL_EXPORTER_OTLP_ENDPOINT=http://jaeger:4317

# Pool de conexões
DB_MAX_IDLE_CONNS=10
DB_MAX_OPEN_CONNS=100
DB_CONN_MAX_LIFETIME=1h
DB_CONN_MAX_IDLE_TIME=30m
```

---

## Gerar Secrets

```bash
# Secret genérico (SECRET_KEY_BASE, JWT_SECRET_KEY, etc.)
openssl rand -base64 48

# Fernet key (ENCRYPTION_KEY)
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"

# Token hex aleatório (EVOAI_CRM_API_TOKEN)
openssl rand -hex 32
```

---

## Estratégia de Testes

### evo-core (Go)
```bash
make test              # Todos os testes
go test ./pkg/...      # Apenas testes de domínio
go test -race ./...    # Com race detector
go test -cover ./...   # Com cobertura
```

**Estrutura de testes:**
- `*_test.go` ao lado dos arquivos de produção
- Testes unitários por módulo de domínio
- Testes de integração requerem banco local rodando

### evo-auth / evo-crm (Ruby)
```bash
bundle exec rspec          # Todos os testes
bundle exec rspec spec/models/    # Apenas models
bundle exec rspec --format documentation
```

### evo-processor (Python)
```bash
pytest                     # Todos os testes
pytest tests/unit/         # Apenas unitários
pytest -v --cov=app        # Com cobertura
```

---

## Logs e Debugging

```bash
# Ver logs de um serviço específico
docker-compose -f docker-compose.dokploy.yaml logs -f evo-core
docker-compose -f docker-compose.dokploy.yaml logs -f evo-crm
docker-compose -f docker-compose.dokploy.yaml logs -f evo-auth

# Ver todos os logs
docker-compose -f docker-compose.dokploy.yaml logs -f

# Entrar no container
docker-compose -f docker-compose.dokploy.yaml exec evo-core sh
docker-compose -f docker-compose.dokploy.yaml exec postgres psql -U postgres evo_community
```

---

## Adicionando um Novo Módulo no evo-core

Siga o padrão DDD estabelecido:

```bash
# 1. Criar estrutura
mkdir -p pkg/meu_modulo/{handler,service,repository,model}
touch pkg/meu_modulo/module.go

# 2. Implementar na ordem:
# model/   → structs de dados
# repository/ → queries GORM com filtro account_id
# service/    → lógica de negócio
# handler/    → rotas e validações
# module.go   → injeção de dependências

# 3. Criar migração
make migrate-create NAME=create_meu_modulo_table

# 4. Registrar rotas em cmd/api/main.go
```

**Referência**: Ver implementação existente em `pkg/agent/` como modelo canônico.
