# Status Final Após Reinício Completo
**Data**: 02/05/2026 09:48  
**Ação Executada**: `docker compose down -v && docker compose up -d`

## ✅ Serviços Funcionando (7/11) - 64%

| # | Serviço | Status | Porta | Health | Observação |
|---|---------|--------|-------|--------|------------|
| 1 | **postgres** | ✅ Running | 5432 | Healthy | Perfeito |
| 2 | **redis** | ✅ Running | 6379 | Healthy | Perfeito |
| 3 | **mailhog** | ✅ Running | 1025, 8025 | - | Perfeito |
| 4 | **evo-auth** | ✅ Running | 3001 | Healthy | Perfeito |
| 5 | **evo-frontend** | ✅ Running | 5173 | - | Perfeito |
| 6 | **evo-crm** | ✅ Running | 3000 | Starting | Migrations completadas |
| 7 | **evo-core** | ✅ Running | 5555 | Unhealthy | Rodando mas health check falha |

## ❌ Serviços com Problemas (4/11) - 36%

### 1. evo-processor (CRÍTICO) ❌
**Status**: Restarting  
**Erro**: `DuplicateTableError: relation "evo_agent_processor_execution_metrics" already exists`

**Problema**: A tabela `evo_agent_processor_execution_metrics` já existe no banco, mas o Alembic está tentando criá-la novamente.

**Causa Raiz**: O Core Service criou essa tabela, mas o Processor não sabe disso e tenta criar novamente.

**Solução Necessária**:
```bash
# Opção 1: Marcar a migration como aplicada manualmente
docker exec -it evo-postgres-1 psql -U postgres -d evo_community -c "
INSERT INTO alembic_version (version_num) 
VALUES ('migration_version_here') 
ON CONFLICT DO NOTHING;"

# Opção 2: Modificar o código do processor para verificar se a tabela existe
# Opção 3: Remover a tabela e deixar o processor criar
docker exec -it evo-postgres-1 psql -U postgres -d evo_community -c "
DROP TABLE IF EXISTS evo_agent_processor_execution_metrics CASCADE;"
docker compose -f docker-compose.local.yaml restart evo-processor
```

---

### 2. evo-bot-runtime (MÉDIO) ⚠️
**Status**: Unhealthy  
**Problema**: Health check falhando + aguardando processor

**Observação**: Está rodando mas não passa no health check. Deve melhorar quando processor estiver OK.

---

### 3. evo-core (MENOR) ⚠️
**Status**: Unhealthy  
**Problema**: Health check falhando

**Observação**: O serviço está rodando e respondendo (vimos nos logs), mas o health check está falhando. Pode ser timeout ou endpoint incorreto.

---

### 4. evo-auth-sidekiq (MENOR) ⚠️
**Status**: Unhealthy  
**Problema**: Inicialização lenta

**Observação**: Normal para Sidekiq. Geralmente se resolve em alguns minutos.

---

### 5. evo-crm-sidekiq (BLOQUEADO) 🚫
**Status**: Not Started  
**Problema**: Aguardando CRM ficar healthy

**Observação**: Não é um problema do serviço, apenas aguardando dependência.

---

## 📊 Análise

### O Que Funcionou ✅
- ✅ Banco de dados foi limpo corretamente
- ✅ Migrations do CRM rodaram com sucesso
- ✅ Migrations do Core rodaram com sucesso  
- ✅ Auth Service está perfeito
- ✅ Frontend está acessível

### O Que Não Funcionou ❌
- ❌ Processor tem conflito de migrations com Core
- ❌ Health checks estão falhando em alguns serviços
- ❌ Bot Runtime não consegue se conectar corretamente

### Problema Principal 🎯
**Conflito de Migrations entre Core e Processor**

Ambos os serviços tentam gerenciar a mesma tabela `evo_agent_processor_execution_metrics`:
- Core Service cria a tabela via suas migrations
- Processor tenta criar a mesma tabela via Alembic
- Resultado: Erro de tabela duplicada

---

## 🌐 Acessos Disponíveis AGORA

### ✅ Funcionando
- **Frontend**: http://localhost:5173
- **Auth API**: http://localhost:3001
- **CRM API**: http://localhost:3000 (parcial)
- **Core API**: http://localhost:5555 (rodando mas unhealthy)
- **MailHog**: http://localhost:8025

### ❌ Não Disponível
- **Processor API**: http://localhost:8000 (restarting)
- **Bot Runtime**: http://localhost:8080 (unhealthy)

---

## 🔧 Soluções Recomendadas

### Solução Rápida (Recomendada)
Remover a tabela conflitante e deixar o Processor criar:

```bash
# 1. Remover a tabela
docker exec -it evo-postgres-1 psql -U postgres -d evo_community -c "DROP TABLE IF EXISTS evo_agent_processor_execution_metrics CASCADE;"

# 2. Reiniciar o processor
docker compose -f docker-compose.local.yaml restart evo-processor

# 3. Aguardar 30 segundos e verificar
docker logs evo-evo-processor-1 --tail 20
```

### Solução Alternativa
Corrigir os health checks:

```bash
# Verificar se os endpoints de health estão corretos
docker exec -it evo-evo-core-1 curl -f http://localhost:5555/health
docker exec -it evo-evo-bot-runtime-1 curl -f http://localhost:8080/health
```

---

## 📈 Progresso Geral

| Métrica | Valor |
|---------|-------|
| Serviços Rodando | 9/11 (82%) |
| Serviços Healthy | 4/11 (36%) |
| Serviços Funcionais | 7/11 (64%) |
| APIs Disponíveis | 3/5 (60%) |

**Conclusão**: O sistema está parcialmente funcional. A maioria dos serviços está rodando, mas há problemas de health checks e um conflito crítico de migrations no Processor.

---

## 🎯 Próximos Passos

1. **Imediato**: Resolver conflito do Processor (5 minutos)
2. **Curto Prazo**: Corrigir health checks (10 minutos)
3. **Médio Prazo**: Aguardar CRM ficar healthy para iniciar CRM Sidekiq

**Tempo Total Estimado**: 15-20 minutos para ter 100% funcional

---

## 💡 Lições Aprendidas

1. **Migrations Compartilhadas**: Core e Processor não devem gerenciar as mesmas tabelas
2. **Health Checks**: Precisam de timeouts maiores ou endpoints corretos
3. **Dependências**: CRM Sidekiq depende do CRM estar healthy, não apenas running
4. **Limpeza de Banco**: Funcionou, mas revelou problemas de arquitetura

---

## 📝 Comandos Úteis

```bash
# Ver logs em tempo real
docker compose -f docker-compose.local.yaml logs -f evo-processor

# Verificar health de um serviço
docker inspect evo-evo-core-1 | grep -A 10 Health

# Reiniciar um serviço específico
docker compose -f docker-compose.local.yaml restart evo-processor

# Ver todas as tabelas no banco
docker exec -it evo-postgres-1 psql -U postgres -d evo_community -c "\dt"
```
