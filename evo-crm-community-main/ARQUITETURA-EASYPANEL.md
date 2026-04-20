# 🏗️ Arquitetura EVO CRM Community no EasyPanel

## Diagrama de Infraestrutura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           EASYPANEL PROJECT                              │
│                         evo-crm-community                                │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                          CAMADA DE FRONTEND                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌────────────────────────────────────────────────────────────┐         │
│  │  EVO Frontend (React/Vite)                                 │         │
│  │  Porta: 80                                                 │         │
│  │  Domínio: evo.seudominio.com                              │         │
│  │  Recursos: 0.5 CPU, 256 MB RAM                           │         │
│  │  Health: /health                                          │         │
│  └────────────────────────────────────────────────────────────┘         │
│                              │                                           │
│                              │ HTTPS                                     │
│                              ▼                                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                        CAMADA DE APLICAÇÃO                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────────┐  ┌──────────────────────┐                    │
│  │  Auth Service        │  │  Auth Sidekiq        │                    │
│  │  (Ruby/Rails)        │  │  (Worker)            │                    │
│  │  Porta: 3001         │  │  Sem porta           │                    │
│  │  auth.seudominio.com │  │                      │                    │
│  │  1 CPU, 1 GB RAM     │  │  0.5 CPU, 512 MB     │                    │
│  └──────────────────────┘  └──────────────────────┘                    │
│           │                          │                                   │
│           │                          │                                   │
│  ┌──────────────────────┐  ┌──────────────────────┐                    │
│  │  CRM Service         │  │  CRM Sidekiq         │                    │
│  │  (Ruby/Rails)        │  │  (Worker)            │                    │
│  │  Porta: 3000         │  │  Sem porta           │                    │
│  │  api.seudominio.com  │  │                      │                    │
│  │  2 CPU, 2 GB RAM     │  │  1 CPU, 1 GB RAM     │                    │
│  └──────────────────────┘  └──────────────────────┘                    │
│           │                          │                                   │
│           │                          │                                   │
│  ┌──────────────────────┐                                               │
│  │  Core Service        │                                               │
│  │  (Go/Gin)            │                                               │
│  │  Porta: 5555         │                                               │
│  │  core.seudominio.com │                                               │
│  │  1 CPU, 1 GB RAM     │                                               │
│  └──────────────────────┘                                               │
│           │                                                              │
│           │                                                              │
│  ┌──────────────────────┐                                               │
│  │  Processor Service   │                                               │
│  │  (Python/FastAPI)    │                                               │
│  │  Porta: 8000         │                                               │
│  │  processor.seudominio│                                               │
│  │  2 CPU, 2 GB RAM     │                                               │
│  └──────────────────────┘                                               │
│           │                                                              │
│           │                                                              │
│  ┌──────────────────────┐                                               │
│  │  Bot Runtime         │                                               │
│  │  (Go/Gin)            │                                               │
│  │  Porta: 8080         │                                               │
│  │  bot.seudominio.com  │                                               │
│  │  1 CPU, 512 MB RAM   │                                               │
│  └──────────────────────┘                                               │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              │ DNS Interno
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        CAMADA DE DADOS                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────────────┐  ┌──────────────────────┐                    │
│  │  PostgreSQL          │  │  Redis               │                    │
│  │  (pgvector)          │  │  (alpine)            │                    │
│  │  Porta: 5432         │  │  Porta: 6379         │                    │
│  │  Externo (já existe) │  │  0.5 CPU, 512 MB     │                    │
│  │  Database:           │  │  Volume: 2 GB        │                    │
│  │  evo_community       │  │  Persistência: ON    │                    │
│  └──────────────────────┘  └──────────────────────┘                    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Fluxo de Comunicação

### 1. Autenticação (Login)

```
┌─────────┐     HTTPS      ┌──────────┐     HTTP      ┌──────────┐
│ Browser │ ──────────────> │ Frontend │ ────────────> │   Auth   │
│         │                 │          │               │ Service  │
└─────────┘                 └──────────┘               └──────────┘
                                                             │
                                                             │ SQL
                                                             ▼
                                                        ┌──────────┐
                                                        │PostgreSQL│
                                                        └──────────┘
```

### 2. Criação de Conversa

```
┌─────────┐     HTTPS      ┌──────────┐     HTTP      ┌──────────┐
│ Browser │ ──────────────> │ Frontend │ ────────────> │   CRM    │
│         │                 │          │               │ Service  │
└─────────┘                 └──────────┘               └──────────┘
                                                             │
                                                             │ SQL
                                                             ▼
                                                        ┌──────────┐
                                                        │PostgreSQL│
                                                        └──────────┘
```

### 3. Processamento de Mensagem com Bot

```
┌──────────┐     HTTP      ┌──────────┐     HTTP      ┌──────────┐
│   CRM    │ ────────────> │   Bot    │ ────────────> │Processor │
│ Service  │               │ Runtime  │               │ Service  │
└──────────┘               └──────────┘               └──────────┘
     │                          │                           │
     │                          │ Redis                     │
     │                          │ (debounce)                │
     │                          ▼                           │
     │                     ┌──────────┐                     │
     │                     │  Redis   │                     │
     │                     └──────────┘                     │
     │                                                      │
     │                                                      │ HTTP
     │                                                      ▼
     │                                                 ┌──────────┐
     │                                                 │   Core   │
     │                                                 │ Service  │
     │                                                 └──────────┘
     │                                                      │
     │                                                      │ SQL
     │                                                      ▼
     │                                                 ┌──────────┐
     │                                                 │PostgreSQL│
     │                                                 └──────────┘
     │
     │ Postback
     │ (resposta)
     ◄────────────────────────────────────────────────────────────
```

### 4. Notificações em Tempo Real

```
┌─────────┐   WebSocket    ┌──────────┐  ActionCable  ┌──────────┐
│ Browser │ <═════════════> │ Frontend │ <═══════════> │   CRM    │
│         │                 │          │               │ Service  │
└─────────┘                 └──────────┘               └──────────┘
                                                             │
                                                             │ Redis
                                                             │ (pub/sub)
                                                             ▼
                                                        ┌──────────┐
                                                        │  Redis   │
                                                        └──────────┘
```

### 5. Jobs Assíncronos (Sidekiq)

```
┌──────────┐     Enqueue    ┌──────────┐    Process    ┌──────────┐
│   Auth   │ ──────────────> │  Redis   │ <──────────── │   Auth   │
│ Service  │                 │  Queue   │               │ Sidekiq  │
└──────────┘                 └──────────┘               └──────────┘

┌──────────┐     Enqueue    ┌──────────┐    Process    ┌──────────┐
│   CRM    │ ──────────────> │  Redis   │ <──────────── │   CRM    │
│ Service  │                 │  Queue   │               │ Sidekiq  │
└──────────┘                 └──────────┘               └──────────┘
```

---

## Dependências entre Serviços

### Ordem de Inicialização (CRÍTICA)

```
1. PostgreSQL (já existe)
   └─> 2. Redis
       └─> 3. Auth Service
           └─> 4. Auth Sidekiq
               └─> 5. CRM Service
                   └─> 6. CRM Sidekiq
                       └─> 7. Core Service
                           └─> 8. Processor Service
                               └─> 9. Bot Runtime
                                   └─> 10. Frontend
```

### Matriz de Dependências

| Serviço | Depende de |
|---------|------------|
| Redis | - |
| Auth | PostgreSQL, Redis |
| Auth Sidekiq | PostgreSQL, Redis, Auth |
| CRM | PostgreSQL, Redis, Auth |
| CRM Sidekiq | PostgreSQL, Redis, CRM |
| Core | PostgreSQL, Auth |
| Processor | PostgreSQL, Redis, Auth, Core |
| Bot Runtime | Redis, Processor |
| Frontend | Auth, CRM, Core, Processor |

---

## Comunicação entre Serviços

### URLs Internas (DNS do EasyPanel)

```
Service Name         Internal URL                  Port
─────────────────────────────────────────────────────────
evo-auth             http://evo-auth:3001          3001
evo-crm              http://evo-crm:3000           3000
evo-core             http://evo-core:5555          5555
evo-processor        http://evo-processor:8000     8000
evo-bot-runtime      http://evo-bot-runtime:8080   8080
redis                redis:6379                    6379
postgres             <external-host>:5432          5432
```

### URLs Públicas (HTTPS)

```
Service              Public URL                    Exposto
─────────────────────────────────────────────────────────────
Frontend             https://evo.seudominio.com    ✅ Sim
Auth                 https://auth.seudominio.com   ✅ Sim
CRM                  https://api.seudominio.com    ✅ Sim
Core                 https://core.seudominio.com   ✅ Sim
Processor            https://processor.seudominio  ✅ Sim
Bot Runtime          https://bot.seudominio.com    ⚠️ Opcional
Redis                -                             ❌ Não
PostgreSQL           -                             ❌ Não
```

---

## Segurança

### Secrets Compartilhados

```
┌─────────────────────────────────────────────────────────┐
│                    SECRETS CRÍTICOS                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  JWT_SECRET_KEY                                         │
│  └─> Auth, CRM, Core, Processor                        │
│      (DEVE SER IGUAL EM TODOS)                          │
│                                                          │
│  ENCRYPTION_KEY                                         │
│  └─> Core, Processor                                    │
│      (DEVE SER IGUAL EM AMBOS)                          │
│                                                          │
│  BOT_RUNTIME_SECRET                                     │
│  └─> CRM, Bot Runtime                                   │
│      (DEVE SER IGUAL EM AMBOS)                          │
│                                                          │
│  EVOAI_CRM_API_TOKEN                                    │
│  └─> CRM, Processor                                     │
│      (DEVE SER IGUAL EM AMBOS)                          │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Camadas de Segurança

```
┌─────────────────────────────────────────────────────────┐
│  1. HTTPS/TLS (Todos os domínios públicos)             │
├─────────────────────────────────────────────────────────┤
│  2. Bearer Token Authentication (JWT)                   │
├─────────────────────────────────────────────────────────┤
│  3. CORS (Domínios permitidos)                         │
├─────────────────────────────────────────────────────────┤
│  4. Rate Limiting (Por IP/Cliente)                     │
├─────────────────────────────────────────────────────────┤
│  5. Database Encryption (API Keys)                     │
├─────────────────────────────────────────────────────────┤
│  6. Redis Password Protection                          │
├─────────────────────────────────────────────────────────┤
│  7. PostgreSQL SSL (Opcional)                          │
└─────────────────────────────────────────────────────────┘
```

---

## Recursos e Escalabilidade

### Recursos Totais

```
┌─────────────────────────────────────────────────────────┐
│                    RECURSOS TOTAIS                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  CPU Total:     9.5 cores                               │
│  RAM Total:     9 GB                                    │
│  Storage:       ~30 GB (incluindo volumes)              │
│                                                          │
│  Custo estimado: $50-100/mês (dependendo do provider)   │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Pontos de Escalabilidade

```
┌─────────────────────────────────────────────────────────┐
│  SERVIÇO          │  ESCALA HORIZONTAL  │  ESCALA VERTICAL│
├─────────────────────────────────────────────────────────┤
│  Frontend         │  ✅ Sim (stateless) │  ⚠️ Limitado    │
│  Auth             │  ⚠️ Com cuidado     │  ✅ Sim         │
│  Auth Sidekiq     │  ✅ Sim (workers)   │  ✅ Sim         │
│  CRM              │  ⚠️ Com cuidado     │  ✅ Sim         │
│  CRM Sidekiq      │  ✅ Sim (workers)   │  ✅ Sim         │
│  Core             │  ✅ Sim (stateless) │  ✅ Sim         │
│  Processor        │  ✅ Sim (stateless) │  ✅ Sim         │
│  Bot Runtime      │  ⚠️ Com Redis lock  │  ✅ Sim         │
│  Redis            │  ⚠️ Cluster mode    │  ✅ Sim         │
│  PostgreSQL       │  ⚠️ Replicação      │  ✅ Sim         │
└─────────────────────────────────────────────────────────┘
```

---

## Monitoramento

### Health Checks

```
┌─────────────────────────────────────────────────────────┐
│  SERVIÇO          │  ENDPOINT         │  INTERVALO       │
├─────────────────────────────────────────────────────────┤
│  Auth             │  /health          │  30s             │
│  CRM              │  /health/live     │  30s             │
│  Core             │  /health          │  15s             │
│  Processor        │  /health          │  30s             │
│  Bot Runtime      │  /health          │  15s             │
│  Frontend         │  /health          │  15s             │
└─────────────────────────────────────────────────────────┘
```

### Métricas Importantes

```
┌─────────────────────────────────────────────────────────┐
│  MÉTRICA                    │  ALERTA EM                │
├─────────────────────────────────────────────────────────┤
│  CPU Usage                  │  > 80%                    │
│  Memory Usage               │  > 90%                    │
│  Disk Usage                 │  > 85%                    │
│  Response Time              │  > 2s                     │
│  Error Rate                 │  > 5%                     │
│  Restart Count              │  > 3 em 5 min             │
│  Database Connections       │  > 90% do pool            │
│  Redis Memory               │  > 80%                    │
│  Sidekiq Queue Size         │  > 1000 jobs              │
└─────────────────────────────────────────────────────────┘
```

---

## Backup e Disaster Recovery

### Estratégia de Backup

```
┌─────────────────────────────────────────────────────────┐
│  COMPONENTE       │  FREQUÊNCIA       │  RETENÇÃO        │
├─────────────────────────────────────────────────────────┤
│  PostgreSQL       │  Diário (3h)      │  30 dias         │
│  Redis            │  Snapshot (1h)    │  7 dias          │
│  Volumes          │  Semanal          │  4 semanas       │
│  Configurações    │  Git (sempre)     │  Ilimitado       │
└─────────────────────────────────────────────────────────┘
```

### RTO e RPO

```
┌─────────────────────────────────────────────────────────┐
│  Recovery Time Objective (RTO):   < 2 horas             │
│  Recovery Point Objective (RPO):  < 24 horas            │
└─────────────────────────────────────────────────────────┘
```

---

## Troubleshooting Visual

### Fluxo de Diagnóstico

```
                    ┌─────────────────┐
                    │  Serviço falhou │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Ver logs       │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼────────┐    │    ┌────────▼────────┐
     │ Erro de conexão │    │    │  Erro de app    │
     └────────┬────────┘    │    └────────┬────────┘
              │             │              │
     ┌────────▼────────┐    │    ┌────────▼────────┐
     │ Testar DB/Redis │    │    │ Verificar vars  │
     └─────────────────┘    │    └─────────────────┘
                            │
                   ┌────────▼────────┐
                   │ Erro de startup │
                   └────────┬────────┘
                            │
                   ┌────────▼────────┐
                   │ Verificar deps  │
                   └─────────────────┘
```

---

## Conclusão

Esta arquitetura foi projetada para:

✅ **Escalabilidade:** Serviços independentes podem escalar separadamente  
✅ **Resiliência:** Falha de um serviço não derruba toda a stack  
✅ **Manutenibilidade:** Cada serviço pode ser atualizado independentemente  
✅ **Segurança:** Múltiplas camadas de proteção  
✅ **Observabilidade:** Health checks e logs centralizados  
✅ **Performance:** Cache com Redis, connection pooling, workers assíncronos  

**Próximos passos:** Seguir o guia de deploy em `EASYPANEL-QUICK-START.md`
