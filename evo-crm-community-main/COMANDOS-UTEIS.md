# 🛠️ Comandos Úteis - EVO CRM Community

Referência rápida de comandos para desenvolvimento, deploy e troubleshooting.

---

## 🔐 Gerar Secrets

### JWT Secret Key (64 bytes base64)
```bash
openssl rand -base64 64 | tr -d '\n'
```

### Encryption Key (32 bytes URL-safe base64)
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Bot Runtime Secret (32 bytes hex)
```bash
openssl rand -hex 32
```

### UUID (para tokens)
```bash
uuidgen | tr '[:upper:]' '[:lower:]'
```

### Redis Password (32 bytes base64)
```bash
openssl rand -base64 32 | tr -d '\n'
```

### Gerar todos de uma vez
```bash
echo "JWT_SECRET_KEY=$(openssl rand -base64 64 | tr -d '\n')"
echo "ENCRYPTION_KEY=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')"
echo "BOT_RUNTIME_SECRET=$(openssl rand -hex 32)"
echo "EVOAI_CRM_API_TOKEN=$(uuidgen | tr '[:upper:]' '[:lower:]')"
echo "REDIS_PASSWORD=$(openssl rand -base64 32 | tr -d '\n')"
```

---

## 🐳 Docker Local

### Comandos Básicos
```bash
# Iniciar todos os serviços
docker compose up -d

# Parar todos os serviços
docker compose down

# Ver status
docker compose ps

# Ver logs (todos)
docker compose logs -f

# Ver logs de um serviço específico
docker compose logs -f evo-auth
docker compose logs -f evo-crm
docker compose logs -f evo-core

# Reiniciar um serviço
docker compose restart evo-auth

# Rebuild de um serviço
docker compose build evo-auth
docker compose up -d evo-auth

# Rebuild sem cache
docker compose build --no-cache evo-auth

# Remover tudo (incluindo volumes)
docker compose down -v --remove-orphans
```

### Acessar Shell dos Containers
```bash
# Auth Service
docker compose exec evo-auth bash

# CRM Service
docker compose exec evo-crm bash

# Core Service
docker compose exec evo-core sh

# Processor Service
docker compose exec evo-processor bash

# Bot Runtime
docker compose exec evo-bot-runtime sh

# PostgreSQL
docker compose exec postgres psql -U postgres -d evo_community

# Redis
docker compose exec redis redis-cli -a sua-senha
```

---

## 🗄️ PostgreSQL

### Conexão
```bash
# Conectar ao banco
psql -h localhost -U postgres -d evo_community

# Conectar remotamente
psql -h seu-host -U seu-usuario -d evo_community
```

### Comandos Úteis
```sql
-- Listar databases
\l

-- Conectar a um database
\c evo_community

-- Listar tabelas
\dt

-- Listar extensões
\dx

-- Ver estrutura de uma tabela
\d evo_core_agents

-- Ver tamanho do database
SELECT pg_size_pretty(pg_database_size('evo_community'));

-- Ver tamanho de cada tabela
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Instalar extensões
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Ver conexões ativas
SELECT * FROM pg_stat_activity WHERE datname = 'evo_community';

-- Matar conexões (cuidado!)
SELECT pg_terminate_backend(pid) 
FROM pg_stat_activity 
WHERE datname = 'evo_community' AND pid <> pg_backend_pid();
```

### Backup e Restore
```bash
# Backup completo
pg_dump -h localhost -U postgres -d evo_community -F c -f backup_$(date +%Y%m%d_%H%M%S).dump

# Backup SQL
pg_dump -h localhost -U postgres -d evo_community > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore de dump
pg_restore -h localhost -U postgres -d evo_community backup.dump

# Restore de SQL
psql -h localhost -U postgres -d evo_community < backup.sql

# Backup apenas schema
pg_dump -h localhost -U postgres -d evo_community --schema-only > schema.sql

# Backup apenas dados
pg_dump -h localhost -U postgres -d evo_community --data-only > data.sql
```

---

## 🔴 Redis

### Conexão
```bash
# Conectar localmente
redis-cli

# Conectar com senha
redis-cli -a sua-senha

# Conectar remotamente
redis-cli -h redis-host -p 6379 -a sua-senha
```

### Comandos Úteis
```bash
# Testar conexão
PING

# Ver informações
INFO

# Ver memória
INFO memory

# Ver estatísticas
INFO stats

# Listar todas as keys
KEYS *

# Listar keys por padrão
KEYS evo:*
KEYS sidekiq:*

# Ver valor de uma key
GET key_name

# Ver tipo de uma key
TYPE key_name

# Ver TTL de uma key
TTL key_name

# Deletar uma key
DEL key_name

# Deletar todas as keys (CUIDADO!)
FLUSHDB

# Deletar todas as keys de todos os databases (MUITO CUIDADO!)
FLUSHALL

# Ver tamanho de uma key
MEMORY USAGE key_name

# Monitorar comandos em tempo real
MONITOR

# Ver configuração
CONFIG GET *

# Salvar snapshot
SAVE

# Salvar snapshot em background
BGSAVE
```

---

## 🚂 Rails (Auth e CRM)

### Console
```bash
# Abrir console Rails
bundle exec rails console

# Abrir console em produção
RAILS_ENV=production bundle exec rails console
```

### Comandos no Console
```ruby
# Ver usuários
User.all
User.count
User.find_by(email: 'support@evo-auth-service-community.com')

# Criar usuário
User.create!(
  email: 'novo@exemplo.com',
  password: 'senha123',
  password_confirmation: 'senha123',
  confirmed: true
)

# Atualizar usuário
user = User.find_by(email: 'user@exemplo.com')
user.update!(password: 'nova_senha')

# Ver contas
Account.all
Account.count

# Ver conversas
Conversation.all
Conversation.count

# Limpar cache
Rails.cache.clear

# Ver configuração
Rails.application.config

# Testar Redis
Sidekiq.redis { |conn| conn.ping }

# Ver filas Sidekiq
Sidekiq::Queue.all.map(&:name)
Sidekiq::Queue.new('default').size

# Limpar fila
Sidekiq::Queue.new('default').clear
```

### Database
```bash
# Criar database
bundle exec rails db:create

# Executar migrations
bundle exec rails db:migrate

# Rollback última migration
bundle exec rails db:rollback

# Rollback N migrations
bundle exec rails db:rollback STEP=3

# Ver status das migrations
bundle exec rails db:migrate:status

# Resetar database (CUIDADO!)
bundle exec rails db:reset

# Preparar database (create + migrate)
bundle exec rails db:prepare

# Executar seeds
bundle exec rails db:seed

# Resetar e seed
bundle exec rails db:reset db:seed
```

### Sidekiq
```bash
# Iniciar Sidekiq
bundle exec sidekiq

# Iniciar com config específica
bundle exec sidekiq -C config/sidekiq.yml

# Ver jobs
bundle exec rails runner "puts Sidekiq::Queue.new('default').size"

# Limpar fila
bundle exec rails runner "Sidekiq::Queue.new('default').clear"
```

---

## 🐹 Go (Core e Bot Runtime)

### Build e Run
```bash
# Build
go build -o bin/app cmd/api/main.go

# Run
go run cmd/api/main.go

# Run com .env
go run cmd/api/main.go -dev

# Build para produção
CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bin/app cmd/api/main.go

# Tidy modules
go mod tidy

# Download dependencies
go mod download

# Verify dependencies
go mod verify
```

### Migrations (Core)
```bash
# Instalar migrate
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Criar migration
migrate create -ext sql -dir migrations -seq nome_da_migration

# Executar migrations
migrate -path migrations -database "postgresql://user:pass@localhost:5432/evo_community?sslmode=disable" up

# Rollback
migrate -path migrations -database "postgresql://user:pass@localhost:5432/evo_community?sslmode=disable" down 1

# Ver versão
migrate -path migrations -database "postgresql://user:pass@localhost:5432/evo_community?sslmode=disable" version
```

---

## 🐍 Python (Processor)

### Virtual Environment
```bash
# Criar venv
python3 -m venv venv

# Ativar venv (Linux/Mac)
source venv/bin/activate

# Ativar venv (Windows)
venv\Scripts\activate

# Desativar
deactivate
```

### Dependências
```bash
# Instalar dependências
pip install -r requirements.txt

# Instalar em modo desenvolvimento
pip install -e .

# Atualizar requirements
pip freeze > requirements.txt

# Instalar pacote específico
pip install nome-do-pacote

# Desinstalar pacote
pip uninstall nome-do-pacote
```

### Run
```bash
# Iniciar servidor
uvicorn src.main:app --host 0.0.0.0 --port 8000

# Iniciar com reload
uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload

# Iniciar em produção
uvicorn src.main:app --host 0.0.0.0 --port 8000 --workers 4
```

### Alembic (Migrations)
```bash
# Criar migration
alembic revision --autogenerate -m "descrição"

# Executar migrations
alembic upgrade head

# Rollback
alembic downgrade -1

# Ver histórico
alembic history

# Ver versão atual
alembic current
```

---

## ⚛️ React (Frontend)

### Desenvolvimento
```bash
# Instalar dependências
pnpm install

# Iniciar dev server
pnpm run dev

# Build para produção
pnpm run build

# Preview da build
pnpm run preview

# Lint
pnpm run eslint

# Lint e fix
pnpm run eslint:fix

# Testes
pnpm run test

# Testes em watch mode
pnpm run test:watch

# Coverage
pnpm run test:coverage
```

---

## 🔍 Troubleshooting

### Ver Logs
```bash
# Docker Compose
docker compose logs -f --tail=100 evo-auth
docker compose logs -f --tail=100 evo-crm

# Kubernetes (se usar)
kubectl logs -f deployment/evo-auth
kubectl logs -f deployment/evo-crm

# Systemd (se usar)
journalctl -u evo-auth -f
journalctl -u evo-crm -f
```

### Testar Conectividade
```bash
# Testar porta
nc -zv localhost 3001
telnet localhost 3001

# Testar HTTP
curl http://localhost:3001/health
curl -I http://localhost:3001/health

# Testar HTTPS
curl https://auth.seudominio.com/health
curl -I https://auth.seudominio.com/health

# Testar DNS
nslookup auth.seudominio.com
dig auth.seudominio.com

# Testar PostgreSQL
pg_isready -h localhost -p 5432

# Testar Redis
redis-cli -h localhost -p 6379 ping
```

### Verificar Recursos
```bash
# CPU e Memória
top
htop

# Disco
df -h
du -sh *

# Processos
ps aux | grep ruby
ps aux | grep go
ps aux | grep python

# Portas em uso
netstat -tulpn | grep LISTEN
lsof -i :3001
```

---

## 📊 Monitoramento

### Health Checks
```bash
# Todos os serviços
curl https://auth.seudominio.com/health
curl https://api.seudominio.com/health/live
curl https://core.seudominio.com/health
curl https://processor.seudominio.com/health
curl https://bot.seudominio.com/health

# Script para testar todos
#!/bin/bash
services=(
  "https://auth.seudominio.com/health"
  "https://api.seudominio.com/health/live"
  "https://core.seudominio.com/health"
  "https://processor.seudominio.com/health"
)

for service in "${services[@]}"; do
  echo "Testing $service"
  curl -f -s -o /dev/null -w "%{http_code}\n" "$service"
done
```

### Métricas
```bash
# PostgreSQL
psql -c "SELECT count(*) FROM pg_stat_activity WHERE datname = 'evo_community';"

# Redis
redis-cli INFO stats | grep total_commands_processed
redis-cli INFO memory | grep used_memory_human

# Sidekiq
bundle exec rails runner "puts Sidekiq::Stats.new.inspect"
```

---

## 🔄 CI/CD

### GitHub Actions (exemplo)
```yaml
name: Deploy to EasyPanel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy
        run: |
          # Seus comandos de deploy aqui
```

---

## 📝 Notas

- Sempre fazer backup antes de operações destrutivas
- Testar em staging antes de produção
- Documentar mudanças
- Monitorar após mudanças

---

**Última atualização:** 2025-04-20  
**Versão:** 1.0
