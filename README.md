# 🚀 EVO CRM Community - Deploy Ready

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-tonygomes--wq%2Fevo-181717?logo=github)](https://github.com/tonygomes-wq/evo)
[![EasyPanel](https://img.shields.io/badge/Deploy-EasyPanel-00D9FF)](https://easypanel.io)
[![Documentation](https://img.shields.io/badge/Docs-Complete-green)](INDICE-DOCUMENTACAO.md)

> Plataforma completa de CRM com IA - Pronta para deploy no EasyPanel

Este repositório contém o **EVO CRM Community** com toda a documentação necessária para deploy no **EasyPanel**, incluindo guias detalhados, checklists e templates de configuração.

---

## 🎯 Início Rápido

### Escolha seu caminho:

| Você é... | Comece aqui | Tempo |
|-----------|-------------|-------|
| 🚀 **DevOps** (Deploy EasyPanel) | [EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md) | 30 min |
| 👨‍💻 **Desenvolvedor** (Local) | [Makefile](evo-crm-community-main/Makefile) → `make setup` | 10 min |
| 🏗️ **Arquiteto** (Entender) | [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md) | 30 min |
| 📊 **Gestor** (Visão Geral) | [RESUMO-EXECUTIVO.md](RESUMO-EXECUTIVO.md) | 10 min |

---

## 📚 Documentação Completa

### 🌟 Documentos Principais

| Documento | Descrição | Tempo |
|-----------|-----------|-------|
| **[📖 INDICE-DOCUMENTACAO.md](INDICE-DOCUMENTACAO.md)** | Índice completo de toda documentação | 5 min |
| **[⚡ EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md)** | Guia rápido de deploy (30 min) | ⚡ Rápido |
| **[📖 DOCUMENTACAO-LOCAL-EASYPANEL.md](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md)** | Documentação completa e detalhada | 📖 Completo |
| **[🏗️ ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md)** | Diagramas e arquitetura visual | 🏗️ Técnico |
| **[✅ CHECKLIST-DEPLOY-EASYPANEL.md](evo-crm-community-main/CHECKLIST-DEPLOY-EASYPANEL.md)** | Checklist interativo de deploy | ✅ Prático |
| **[📊 RESUMO-EXECUTIVO.md](RESUMO-EXECUTIVO.md)** | Análise de viabilidade e plano | 📊 Executivo |
| **[🛠️ COMANDOS-UTEIS.md](evo-crm-community-main/COMANDOS-UTEIS.md)** | Referência rápida de comandos | 🛠️ Referência |

### 📋 Templates e Configuração

| Arquivo | Descrição |
|---------|-----------|
| **[.env.easypanel.template](evo-crm-community-main/.env.easypanel.template)** | Template completo de variáveis de ambiente |
| **[.env.example](evo-crm-community-main/.env.example)** | Exemplo de configuração local |
| **[docker-compose.yml](evo-crm-community-main/docker-compose.yml)** | Orquestração Docker completa |
| **[Makefile](evo-crm-community-main/Makefile)** | Comandos úteis para desenvolvimento |

---

## 🏗️ Arquitetura

O projeto é composto por **6 microserviços independentes**:

```
┌─────────────────────────────────────────────────────────┐
│  Frontend (React)     →  Porta 5173                     │
│  Auth Service (Rails) →  Porta 3001                     │
│  CRM Service (Rails)  →  Porta 3000                     │
│  Core Service (Go)    →  Porta 5555                     │
│  Processor (Python)   →  Porta 8000                     │
│  Bot Runtime (Go)     →  Porta 8080                     │
└─────────────────────────────────────────────────────────┘
         ↓                    ↓
┌──────────────────┐  ┌──────────────────┐
│  PostgreSQL      │  │  Redis           │
│  (pgvector)      │  │  (alpine)        │
└──────────────────┘  └──────────────────┘
```

**Recursos necessários:**
- CPU: ~9.5 cores
- RAM: ~9 GB
- Storage: ~30 GB

**Detalhes:** [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md)

---

## ⚡ Quick Start

### Opção 1: Deploy no EasyPanel (Recomendado)

1. **Preparar secrets:**
```bash
# Gerar JWT_SECRET_KEY
openssl rand -base64 64 | tr -d '\n'

# Gerar ENCRYPTION_KEY
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Gerar BOT_RUNTIME_SECRET
openssl rand -hex 32

# Gerar EVOAI_CRM_API_TOKEN
uuidgen | tr '[:upper:]' '[:lower:]'
```

2. **Seguir o guia:**
   - 📖 [EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md) - Deploy em 30 minutos

3. **Usar o checklist:**
   - ✅ [CHECKLIST-DEPLOY-EASYPANEL.md](evo-crm-community-main/CHECKLIST-DEPLOY-EASYPANEL.md)

### Opção 2: Desenvolvimento Local

```bash
# Clone o repositório
git clone https://github.com/tonygomes-wq/evo.git
cd evo/evo-crm-community-main

# Setup completo (primeira vez)
make setup

# Iniciar serviços
make start

# Ver logs
make logs

# Parar serviços
make stop
```

**Acessar:**
- Frontend: http://localhost:5173
- CRM API: http://localhost:3000
- Auth API: http://localhost:3001
- Core API: http://localhost:5555
- Processor: http://localhost:8000

**Login padrão:**
- Email: `support@evo-auth-service-community.com`
- Senha: `Password@123`

---

## 📦 Estrutura do Repositório

```
evo/
├── evo-crm-community-main/              # Projeto principal (monorepo)
│   ├── evo-auth-service-community/      # Serviço de autenticação
│   ├── evo-ai-crm-community/            # Serviço CRM
│   ├── evo-ai-core-service-community/   # Serviço Core (agentes IA)
│   ├── evo-ai-processor-community/      # Processador de IA
│   ├── evo-bot-runtime/                 # Runtime de bots
│   ├── evo-ai-frontend-community/       # Frontend React
│   │
│   ├── 📖 DOCUMENTACAO-LOCAL-EASYPANEL.md
│   ├── ⚡ EASYPANEL-QUICK-START.md
│   ├── 🏗️ ARQUITETURA-EASYPANEL.md
│   ├── ✅ CHECKLIST-DEPLOY-EASYPANEL.md
│   ├── 🛠️ COMANDOS-UTEIS.md
│   ├── 📋 .env.easypanel.template
│   ├── 🐳 docker-compose.yml
│   └── 🛠️ Makefile
│
├── 📊 RESUMO-EXECUTIVO.md
├── 📚 INDICE-DOCUMENTACAO.md
└── 📖 README.md (este arquivo)
```

---

## 🎯 Casos de Uso

### Para Desenvolvedores
- ✅ Ambiente local completo com Docker
- ✅ Hot reload em todos os serviços
- ✅ Logs centralizados
- ✅ Seeds de dados de teste

### Para DevOps
- ✅ Deploy automatizado no EasyPanel
- ✅ Health checks configurados
- ✅ Monitoramento e alertas
- ✅ Backup e disaster recovery

### Para Empresas
- ✅ CRM completo com IA
- ✅ Multi-canal (WhatsApp, Email, SMS)
- ✅ Agentes inteligentes
- ✅ Automação de processos

---

## 🔧 Tecnologias

| Serviço | Stack | Versão |
|---------|-------|--------|
| Auth | Ruby on Rails | 7.1 |
| CRM | Ruby on Rails | 7.1 |
| Core | Go + Gin | 1.24+ |
| Processor | Python + FastAPI | 3.10+ |
| Bot Runtime | Go + Gin | 1.21+ |
| Frontend | React + TypeScript | 19 |
| Database | PostgreSQL + pgvector | 16 |
| Cache | Redis | Alpine |

---

## 📖 Documentação por Serviço

Cada serviço possui sua própria documentação:

- [Auth Service README](evo-auth-service-community-main/README.md)
- [CRM Service README](evo-crm-community-main/README.md)
- [Core Service README](evo-ai-core-service-community-main/README.md)
- [Processor README](evo-ai-processor-community-main/README.md)
- [Frontend README](evo-ai-frontend-community-main/README.md)

---

## 🚀 Deploy no EasyPanel

### Pré-requisitos
- ✅ PostgreSQL com pgvector
- ✅ 6 domínios configurados
- ✅ SMTP configurado
- ✅ ~9.5 CPU cores
- ✅ ~9 GB RAM

### Ordem de Deploy
1. Redis
2. Auth Service + Sidekiq
3. CRM Service + Sidekiq
4. Core Service
5. Processor Service
6. Bot Runtime
7. Frontend

### Tempo Estimado
- Setup inicial: 30-40 minutos
- Configuração completa: 2-4 horas

### Guias Recomendados
1. **Iniciante:** [EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md)
2. **Avançado:** [DOCUMENTACAO-LOCAL-EASYPANEL.md](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md)
3. **Arquiteto:** [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md)

---

## 🔒 Segurança

### Secrets Obrigatórios
- `JWT_SECRET_KEY` - Autenticação JWT
- `ENCRYPTION_KEY` - Criptografia de API keys
- `BOT_RUNTIME_SECRET` - Autenticação do bot
- `EVOAI_CRM_API_TOKEN` - Service-to-service auth
- `REDIS_PASSWORD` - Senha do Redis

### Boas Práticas
- ✅ Rotacionar todos os secrets antes de produção
- ✅ Usar HTTPS em todos os domínios
- ✅ Configurar CORS corretamente
- ✅ Habilitar rate limiting
- ✅ Configurar backup automático

---

## 📊 Monitoramento

### Health Checks
Todos os serviços possuem endpoints de health check:

```bash
curl https://auth.seudominio.com/health
curl https://api.seudominio.com/health/live
curl https://core.seudominio.com/health
curl https://processor.seudominio.com/health
curl https://bot.seudominio.com/health
```

### Métricas Importantes
- CPU Usage (alerta > 80%)
- Memory Usage (alerta > 90%)
- Response Time (alerta > 2s)
- Error Rate (alerta > 5%)
- Restart Count (alerta > 3 em 5 min)

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença Apache 2.0. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 🆘 Suporte

### Documentação
- 📚 [Índice Completo](INDICE-DOCUMENTACAO.md)
- 📖 [Documentação Completa](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md)
- ⚡ [Quick Start](evo-crm-community-main/EASYPANEL-QUICK-START.md)
- 🏗️ [Arquitetura](evo-crm-community-main/ARQUITETURA-EASYPANEL.md)
- ✅ [Checklist](evo-crm-community-main/CHECKLIST-DEPLOY-EASYPANEL.md)

### Comunidade
- 🐛 [Issues](https://github.com/tonygomes-wq/evo/issues)
- 💬 [Discussions](https://github.com/tonygomes-wq/evo/discussions)
- 📧 Email: contato@evolution-api.com

### Links Úteis
- [EasyPanel Docs](https://easypanel.io/docs)
- [Evolution API](https://evolution-api.com)
- [PostgreSQL pgvector](https://github.com/pgvector/pgvector)

---

## 🎉 Agradecimentos

Desenvolvido com ❤️ pela comunidade Evolution API.

Agradecimentos especiais a todos os contribuidores e à comunidade open source.

---

## 📈 Status do Projeto

- ✅ Ambiente local funcionando
- ✅ Documentação completa para EasyPanel
- ✅ Guias de deploy criados
- ✅ Checklists e templates prontos
- ✅ Arquitetura documentada
- 🚧 Deploy em produção (em andamento)

---

**Última atualização:** 2025-04-20  
**Versão:** 2.0 - EasyPanel Ready  
**Repositório:** https://github.com/tonygomes-wq/evo