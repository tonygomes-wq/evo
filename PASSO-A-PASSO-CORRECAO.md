# 🎯 Passo a Passo - Correção dos Serviços

## ⚡ Guia Rápido de Execução (10 minutos)

Siga exatamente esta ordem para corrigir todos os problemas.

---

## 🔧 PASSO 1: Corrigir evo-crm (5 minutos)

### 1.1 Acessar Configurações
```
1. Abrir Easypanel
2. Projeto: evogo
3. Clicar no serviço: evo-crm
4. Clicar na aba: "Ambiente" (Environment)
```

### 1.2 Corrigir Senha do PostgreSQL
```
Localizar: POSTGRES_PASSWORD
Valor ERRADO: 355cbf3375d96724d0ff
Valor CORRETO: 355cbf3375d96724de1f

⚠️ ATENÇÃO: Mudar apenas os últimos 4 caracteres: d0ff → de1f
```

### 2. Corrigir URL do Redis
```
Localizar: REDIS_URL
Valor DEVE SER: redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379

✅ Verificar:
   - Tem "default:" antes da senha
   - Tem arroba (@) depois da senha
   - Senha é: d9kizl4kz7riul5ah7if
```

### 1.4 Salvar e Reiniciar
```
1. Clicar em "Salvar" (Save)
2. Clicar em "Reiniciar" (Restart)
3. Aguardar 30 segundos
4. Verificar logs
```

### 1.5 Verificar Logs
```
Procurar por:
✅ "Puma starting in cluster mode"
✅ "Listening on http://0.0.0.0:3000"

❌ Se aparecer erro de migração (sentiment_offensive):
   → Ir para PASSO 1.6
   
✅ Se não aparecer erro:
   → Ir para PASSO 2
```

### 1.6 Corrigir Erro de Migração (se necessário)
```
1. No serviço evo-crm, clicar em "Console" ou "Terminal"
2. Selecionar "Bash"
3. Copiar e colar este comando:

bundle exec rails runner "ActiveRecord::Base.connection.execute(\"INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING\")"

4. Pressionar Enter
5. Aguardar mensagem de sucesso
6. Fechar console
7. Clicar em "Reiniciar" novamente
8. Verificar logs novamente
```

### 1.7 Testar evo-crm
```bash
# Executar no seu terminal local:
curl https://api.macip.com.br/health/live

# Deve retornar:
{"status":"ok"}
```

---

## 🔧 PASSO 2: Corrigir evo-crm-sidekiq (5 minutos)

### 2.1 Corrigir Caminho de Build
```
1. No Easypanel, serviço: evo-crm-sidekiq
2. Clicar na aba: "Fonte" (Source)
3. Seção: "Github"
4. Localizar: "Caminho de Build" (Build Path)

Valor ERRADO: /evo-ai-crm-community-main
Valor CORRETO: evo-ai-crm-community-main

⚠️ REMOVER a barra inicial (/)
```

### 2.2 Verificar Caminho do Dockerfile
```
Localizar: "Caminho do Dockerfile" (Dockerfile Path)
Valor DEVE SER: docker/Dockerfile

✅ Se estiver correto, continuar
❌ Se estiver diferente, corrigir
```

### 2.3 Corrigir Variáveis de Ambiente
```
1. Clicar na aba: "Ambiente" (Environment)
2. Corrigir POSTGRES_PASSWORD:
   Valor CORRETO: 355cbf3375d96724de1f

3. Corrigir REDIS_URL:
   Valor CORRETO: redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379
```

### 2.4 Salvar e Rebuild
```
1. Clicar em "Salvar" (Save)
2. Clicar em "Rebuild"
3. Aguardar build completar (2-3 minutos)
4. Verificar logs
```

### 2.5 Verificar Logs
```
Procurar por:
✅ "Booting Sidekiq"
✅ "Running in ruby"
✅ "Starting processing"

❌ Se aparecer erro:
   → Verificar se as variáveis estão corretas
   → Verificar se o caminho de build está sem barra inicial
```

---

## ✅ PASSO 3: Verificação Final (2 minutos)

### 3.1 Verificar Status de Todos os Serviços
```
No Easypanel, verificar que TODOS estão com status "Running":

✅ evo-auth
✅ evo-auth-sidekiq
✅ evo-bot-runtime
✅ evo-core
✅ evo-frontend
✅ evo-processor
✅ evo-crm          ← Deve estar Running agora
✅ evo-crm-sidekiq  ← Deve estar Running agora
```

### 3.2 Testar Health Checks
```bash
# Executar no terminal local:

# Auth
curl https://auth.macip.com.br/health

# CRM (principal)
curl https://api.macip.com.br/health/live

# Core
curl https://core.macip.com.br/health

# Processor
curl https://processor.macip.com.br/health

# Bot Runtime
curl https://bot.macip.com.br/health

# Todos devem retornar status OK
```

### 3.3 Testar Login no Frontend
```
1. Abrir navegador
2. Acessar: https://evo.macip.com.br
3. Fazer login:
   Email: support@evo-auth-service-community.com
   Senha: Password@123
4. Deve entrar no dashboard
```

### 3.4 Testar Criação de Conversa
```
1. No dashboard, criar nova conversa
2. Enviar mensagem de teste
3. Verificar se mensagem é enviada
4. Verificar se agente responde
```

---

## 🔍 Troubleshooting Rápido

### Se evo-crm não iniciar:
```
1. Verificar logs completos
2. Procurar por "PG::ConnectionBad" → senha do PostgreSQL errada
3. Procurar por "WRONGPASS" → senha do Redis errada
4. Procurar por "PG::DuplicateColumn" → executar fix da migração
```

### Se evo-crm-sidekiq não buildar:
```
1. Verificar se caminho de build está SEM barra inicial
2. Verificar se Dockerfile path é: docker/Dockerfile
3. Verificar logs de build para outros erros
```

### Se health check falhar:
```
1. Verificar se serviço está realmente Running
2. Verificar logs do serviço
3. Verificar se porta está correta (3000 para CRM)
4. Verificar se domínio está apontando corretamente
```

---

## 📋 Checklist de Verificação

Marque cada item conforme completar:

### evo-crm
- [ ] POSTGRES_PASSWORD corrigido para: `355cbf3375d96724de1f`
- [ ] REDIS_URL corrigido para: `redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0`
- [ ] Serviço reiniciado
- [ ] Logs mostram "Listening on http://0.0.0.0:3000"
- [ ] Health check retorna OK
- [ ] Sem erros de migração

### evo-crm-sidekiq
- [ ] Caminho de build SEM barra inicial: `evo-ai-crm-community-main`
- [ ] Dockerfile path: `docker/Dockerfile`
- [ ] POSTGRES_PASSWORD corrigido
- [ ] REDIS_URL corrigido
- [ ] Build completado com sucesso
- [ ] Logs mostram "Booting Sidekiq"
- [ ] Conectado ao Redis

### Sistema Completo
- [ ] Todos os 8 serviços Running
- [ ] Todos os health checks OK
- [ ] Login funcionando
- [ ] Dashboard carregando
- [ ] Conversa criada com sucesso
- [ ] Mensagens sendo enviadas

---

## 🎯 Valores Corretos - Referência Rápida

### PostgreSQL
```
Host: evogo_postgres
Port: 5432
Username: postgres
Password: 355cbf3375d96724de1f
Database: evo_community
```

### Redis
```
URL: redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379
Password: d9kizl4kz7riul5ah7if
```

### Caminhos no Easypanel
```
Build Path: evo-ai-crm-community-main (SEM barra inicial)
Dockerfile: docker/Dockerfile
```

---

## ⏱️ Tempo Estimado

- Passo 1 (evo-crm): 5 minutos
- Passo 2 (evo-crm-sidekiq): 5 minutos
- Passo 3 (verificação): 2 minutos
- **Total: 12 minutos**

---

## 📞 Próximos Passos

Após todos os serviços estarem funcionando:

1. ✅ Configurar backup automático do PostgreSQL
2. ✅ Configurar monitoramento de logs
3. ✅ Configurar alertas de downtime
4. ✅ Testar fluxo completo de conversação
5. ✅ Configurar integrações (WhatsApp, etc.)

---

**Última atualização:** 21/04/2026
**Dificuldade:** Fácil
**Tempo:** 12 minutos
