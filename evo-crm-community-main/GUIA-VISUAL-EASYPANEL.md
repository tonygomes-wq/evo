# 🎨 Guia Visual - Deploy no EasyPanel

**Repositório GitHub:** https://github.com/tonygomes-wq/evo

---

## 📋 Checklist Rápido

Para cada serviço, você vai:
1. ✅ Criar App "From Source"
2. ✅ Conectar ao GitHub
3. ✅ Configurar Build Path
4. ✅ Adicionar Environment Variables
5. ✅ Deploy!

---

## 🎯 Template de Configuração

### Para TODOS os serviços:

```
┌─────────────────────────────────────────┐
│ 1. CREATE APP                           │
├─────────────────────────────────────────┤
│ Type: From Source                       │
│ Source: GitHub                          │
│ Repository: tonygomes-wq/evo            │
│ Branch: main                            │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 2. BUILD CONFIGURATION                  │
├─────────────────────────────────────────┤
│ Build Type: Dockerfile                  │
│ Build Path: [ver tabela abaixo]        │
│ Dockerfile Path: [ver tabela abaixo]   │
│ Build Context: [mesmo do Build Path]   │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 3. APP CONFIGURATION                    │
├─────────────────────────────────────────┤
│ Name: [ver tabela abaixo]              │
│ Port: [ver tabela abaixo]              │
│ Domain: [seu domínio]                  │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 4. ENVIRONMENT VARIABLES                │
├─────────────────────────────────────────┤
│ [copiar do arquivo .env.production]    │
└─────────────────────────────────────────┘
```

---

## 📊 Tabela de Configuração Rápida

| # | Nome | Build Path | Dockerfile | Port | Domínio |
|---|------|------------|------------|------|---------|
| 1 | `evo-auth` | `/evo-auth-service-community-main` | `Dockerfile` | 3001 | auth.macip.com.br |
| 2 | `evo-auth-sidekiq` | `/evo-auth-service-community-main` | `Dockerfile` | - | - |
| 3 | `evo-crm` | `/evo-crm-community-main/evo-ai-crm-community` | `docker/Dockerfile` | 3000 | api.macip.com.br |
| 4 | `evo-crm-sidekiq` | `/evo-crm-community-main/evo-ai-crm-community` | `docker/Dockerfile` | - | - |
| 5 | `evo-core` | `/evo-ai-core-service-community-main` | `Dockerfile` | 5555 | core.macip.com.br |
| 6 | `evo-processor` | `/evo-ai-processor-community-main` | `Dockerfile` | 8000 | processor.macip.com.br |
| 7 | `evo-bot-runtime` | `/evo-bot-runtime-main` | `Dockerfile` | 8080 | bot.macip.com.br |
| 8 | `evo-frontend` | `/evo-ai-frontend-community-main` | `Dockerfile` | 80 | evo.macip.com.br |

---

## 🔢 Passo a Passo Visual

### Serviço 1: Auth Service

```
┌──────────────────────────────────────────────────────────┐
│ EASYPANEL → Projects → evogo → Add Service              │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ Select: "App"                                            │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ Select: "From Source"                                    │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ SOURCE CONFIGURATION                                     │
├──────────────────────────────────────────────────────────┤
│ Provider: GitHub                                         │
│ Repository: tonygomes-wq/evo                            │
│ Branch: main                                            │
│ Build Path: /evo-auth-service-community-main            │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ BUILD CONFIGURATION                                      │
├──────────────────────────────────────────────────────────┤
│ Build Type: Dockerfile                                   │
│ Dockerfile Path: Dockerfile                              │
│ Build Context: /evo-auth-service-community-main          │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ APP CONFIGURATION                                        │
├──────────────────────────────────────────────────────────┤
│ Name: evo-auth                                          │
│ Port: 3001                                              │
│ Domain: auth.macip.com.br                               │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ ENVIRONMENT VARIABLES                                    │
├──────────────────────────────────────────────────────────┤
│ [Clicar em "Add Variable"]                              │
│                                                          │
│ RAILS_ENV = production                                  │
│ POSTGRES_HOST = evogo_postgres                          │
│ POSTGRES_PASSWORD = 355cbf3375d96724d0ff                │
│ REDIS_URL = redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/1 │
│ SECRET_KEY_BASE = +ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA== │
│ JWT_SECRET_KEY = +ELXdtnIwCC/91zh4HMtHlPAqL1S5wE6efA7+n1acvKdI/uLBlcHnRuGn1gd0J3YJhJzPrRQWYINhblAJ/tMcA== │
│ ... [ver arquivo .env.production para lista completa]   │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ HEALTH CHECK (opcional mas recomendado)                 │
├──────────────────────────────────────────────────────────┤
│ Path: /health                                           │
│ Port: 3001                                              │
│ Interval: 30s                                           │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ [Clicar em "Deploy"]                                    │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│ ✅ Aguardar build completar                             │
│ ✅ Verificar logs                                       │
│ ✅ Testar: curl https://auth.macip.com.br/health        │
└──────────────────────────────────────────────────────────┘
```

---

## 🎯 Dicas Importantes

### ✅ DO (Fazer)

```
✅ Copiar variáveis do arquivo .env.production
✅ Verificar Build Path está correto
✅ Aguardar build completar antes de próximo serviço
✅ Testar health check após cada deploy
✅ Seguir ordem: Auth → CRM → Core → Processor → Bot → Frontend
```

### ❌ DON'T (Não Fazer)

```
❌ Não pular a ordem de deploy
❌ Não esquecer de configurar Build Args no Frontend
❌ Não usar HTTP nas URLs públicas (usar HTTPS)
❌ Não misturar URLs internas com públicas
❌ Não esquecer de executar seeds
```

---

## 🔍 Como Verificar se Está Correto

### Após cada deploy:

```
1. Ver Logs
   ┌────────────────────────────────────┐
   │ EasyPanel → Service → Logs         │
   │ Procurar por erros                 │
   └────────────────────────────────────┘

2. Testar Health Check
   ┌────────────────────────────────────┐
   │ curl https://service.macip.com.br/health │
   │ Deve retornar 200 OK               │
   └────────────────────────────────────┘

3. Verificar Conectividade
   ┌────────────────────────────────────┐
   │ EasyPanel → Service → Terminal     │
   │ ping evogo_postgres                │
   │ ping evogo_redis                   │
   └────────────────────────────────────┘
```

---

## 📱 Atalhos do EasyPanel

```
Criar App:        Projects → evogo → Add Service
Ver Logs:         Service → Logs
Ver Variáveis:    Service → Environment
Rebuild:          Service → Actions → Rebuild
Restart:          Service → Actions → Restart
Terminal:         Service → Terminal
```

---

## 🎨 Fluxo Visual Completo

```
┌─────────────┐
│   GitHub    │
│   tonygomes │
│   -wq/evo   │
└──────┬──────┘
       │
       │ (conectar)
       ↓
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  EasyPanel  │ ──→ │    Build    │ ──→ │   Deploy    │
│   Project   │     │   Docker    │     │  Container  │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                               ↓
                                        ┌─────────────┐
                                        │   Health    │
                                        │   Check     │
                                        └──────┬──────┘
                                               │
                                               ↓
                                        ┌─────────────┐
                                        │   ✅ OK!    │
                                        │   Running   │
                                        └─────────────┘
```

---

## 🚀 Ordem de Deploy Visual

```
1. evo-auth          ✅ Deploy → ✅ Healthy → Executar Seed
   ↓
2. evo-auth-sidekiq  ✅ Deploy → ✅ Running
   ↓
3. evo-crm           ✅ Deploy → ✅ Healthy → Executar Seed
   ↓
4. evo-crm-sidekiq   ✅ Deploy → ✅ Running
   ↓
5. evo-core          ✅ Deploy → ✅ Healthy
   ↓
6. evo-processor     ✅ Deploy → ✅ Healthy
   ↓
7. evo-bot-runtime   ✅ Deploy → ✅ Healthy
   ↓
8. evo-frontend      ✅ Deploy → ✅ Healthy
   ↓
   ✅ TUDO PRONTO!
```

---

## 📞 Precisa de Ajuda?

### Documentação Completa
- [CONFIGURACAO-GITHUB-EASYPANEL.md](CONFIGURACAO-GITHUB-EASYPANEL.md) - Detalhes técnicos
- [EASYPANEL-QUICK-START.md](EASYPANEL-QUICK-START.md) - Guia rápido
- [CHECKLIST-DEPLOY-EASYPANEL.md](CHECKLIST-DEPLOY-EASYPANEL.md) - Checklist completo

### Troubleshooting
- [DOCUMENTACAO-LOCAL-EASYPANEL.md](DOCUMENTACAO-LOCAL-EASYPANEL.md) - Seção de troubleshooting
- [COMANDOS-UTEIS.md](COMANDOS-UTEIS.md) - Comandos de diagnóstico

---

**Repositório:** https://github.com/tonygomes-wq/evo  
**Última atualização:** 2025-04-20  
**Versão:** 1.0 - Visual Guide
