# ✅ Checklist de Deploy - EVO CRM Community no EasyPanel

Use este checklist para garantir que todos os passos foram executados corretamente.

---

## 📋 Fase 0: Preparação (Antes de começar)

### Infraestrutura
- [ ] Conta no EasyPanel criada e ativa
- [ ] PostgreSQL com pgvector instalado e acessível
- [ ] Domínios registrados e disponíveis (6 subdomínios)
- [ ] DNS configurado e apontando para EasyPanel
- [ ] SMTP configurado (Gmail, SendGrid, Mailgun, etc.)
- [ ] Repositórios Git acessíveis (GitHub, GitLab, etc.)

### Secrets Gerados
- [ ] `JWT_SECRET_KEY` gerado (64 bytes base64)
- [ ] `SECRET_KEY_BASE` gerado (mesmo valor do JWT_SECRET_KEY)
- [ ] `DOORKEEPER_JWT_SECRET_KEY` gerado (pode ser igual ao JWT_SECRET_KEY)
- [ ] `ENCRYPTION_KEY` gerado (32 bytes URL-safe base64)
- [ ] `BOT_RUNTIME_SECRET` gerado (32 bytes hex)
- [ ] `EVOAI_CRM_API_TOKEN` gerado (UUID)
- [ ] `REDIS_PASSWORD` gerado (32 bytes base64)
- [ ] Todos os secrets salvos em local seguro (password manager)

### PostgreSQL
- [ ] Database `evo_community` criada
- [ ] Extensão `vector` instalada
- [ ] Extensão `uuid-ossp` instalada
- [ ] Credenciais anotadas (host, port, user, password)
- [ ] Conexão testada com sucesso

### Domínios
- [ ] `evo.macip.com.br` (Frontend)
- [ ] `auth.macip.com.br` (Auth Service)
- [ ] `api.macip.com.br` (CRM Service)
- [ ] `core.macip.com.br` (Core Service)
- [ ] `processor.macip.com.br` (Processor Service)
- [ ] `bot.macip.com.br` (Bot Runtime - opcional)

---

## 📋 Fase 1: Setup Inicial no EasyPanel

### Projeto
- [ ] Projeto `evo-crm-community` criado no EasyPanel
- [ ] Região/servidor selecionado

### Redis
- [ ] Serviço Redis criado
- [ ] Nome: `redis`
- [ ] Versão: `alpine`
- [ ] Senha configurada (usar REDIS_PASSWORD gerado)
- [ ] Persistência habilitada
- [ ] Volume: 2 GB configurado
- [ ] Recursos: 0.5 CPU, 512 MB RAM
- [ ] Status: ✅ Healthy

---

## 📋 Fase 2: Deploy dos Serviços

### 1. Auth Service
- [ ] App `evo-auth` criada
- [ ] Porta `3001` configurada
- [ ] Domínio `auth.macip.com.br` configurado
- [ ] Source GitHub conectado
- [ ] Dockerfile correto selecionado
- [ ] Todas as variáveis de ambiente configuradas
- [ ] Comando de start configurado
- [ ] Health check `/health` configurado
- [ ] Recursos: 1 CPU, 1 GB RAM, 5 GB storage
- [ ] Build iniciado
- [ ] Build concluído com sucesso
- [ ] Container iniciado
- [ ] Health check passando
- [ ] HTTPS/TLS habilitado
- [ ] Endpoint `https://auth.macip.com.br/health` acessível

### 2. Auth Sidekiq
- [ ] App `evo-auth-sidekiq` criada
- [ ] Configurado como worker (sem porta)
- [ ] Source GitHub conectado (mesmo do auth)
- [ ] Todas as variáveis de ambiente configuradas (mesmas do auth)
- [ ] Comando de start configurado
- [ ] Recursos: 0.5 CPU, 512 MB RAM
- [ ] Build concluído com sucesso
- [ ] Container rodando
- [ ] Logs mostrando "Sidekiq starting"

### 3. Auth Seed
- [ ] Conectado ao container `evo-auth`
- [ ] Comando `bundle exec rails db:seed` executado
- [ ] Seed concluído sem erros
- [ ] Usuário padrão criado com sucesso
- [ ] Credenciais testadas:
  - Email: `support@evo-auth-service-community.com`
  - Senha: `Password@123`

### 4. CRM Service
- [ ] App `evo-crm` criada
- [ ] Porta `3000` configurada
- [ ] Domínio `api.macip.com.br` configurado
- [ ] Source GitHub conectado
- [ ] Dockerfile `docker/Dockerfile` selecionado
- [ ] Todas as variáveis de ambiente configuradas
- [ ] URLs internas corretas (http://evo-auth:3001, etc.)
- [ ] Comando de start configurado
- [ ] Health check `/health/live` configurado
- [ ] Recursos: 2 CPU, 2 GB RAM, 10 GB storage
- [ ] Build concluído com sucesso
- [ ] Container iniciado
- [ ] Health check passando
- [ ] HTTPS/TLS habilitado
- [ ] Endpoint `https://api.macip.com.br/health/live` acessível

### 5. CRM Sidekiq
- [ ] App `evo-crm-sidekiq` criada
- [ ] Configurado como worker (sem porta)
- [ ] Source GitHub conectado (mesmo do CRM)
- [ ] Todas as variáveis de ambiente configuradas (mesmas do CRM)
- [ ] Comando de start configurado
- [ ] Recursos: 1 CPU, 1 GB RAM
- [ ] Build concluído com sucesso
- [ ] Container rodando
- [ ] Logs mostrando "Sidekiq starting"

### 6. CRM Seed
- [ ] Conectado ao container `evo-crm`
- [ ] Comando `bundle exec rails db:seed` executado
- [ ] Seed concluído sem erros
- [ ] Inbox padrão criado

### 7. Core Service
- [ ] App `evo-core` criada
- [ ] Porta `5555` configurada
- [ ] Domínio `core.macip.com.br` configurado
- [ ] Source GitHub conectado
- [ ] Todas as variáveis de ambiente configuradas
- [ ] URLs internas corretas
- [ ] Health check `/health` configurado
- [ ] Recursos: 1 CPU, 1 GB RAM, 2 GB storage
- [ ] Build concluído com sucesso
- [ ] Container iniciado
- [ ] Health check passando
- [ ] HTTPS/TLS habilitado
- [ ] Endpoint `https://core.macip.com.br/health` acessível

### 8. Processor Service
- [ ] App `evo-processor` criada
- [ ] Porta `8000` configurada
- [ ] Domínio `processor.macip.com.br` configurado
- [ ] Source GitHub conectado
- [ ] Todas as variáveis de ambiente configuradas
- [ ] Connection string do PostgreSQL correta
- [ ] URLs internas corretas
- [ ] Health check `/health` configurado
- [ ] Recursos: 2 CPU, 2 GB RAM, 5 GB storage
- [ ] Build concluído com sucesso
- [ ] Container iniciado
- [ ] Health check passando
- [ ] HTTPS/TLS habilitado
- [ ] Endpoint `https://processor.macip.com.br/health` acessível

### 9. Bot Runtime
- [ ] App `evo-bot-runtime` criada
- [ ] Porta `8080` configurada
- [ ] Domínio `bot.macip.com.br` configurado (opcional)
- [ ] Source GitHub conectado
- [ ] Todas as variáveis de ambiente configuradas
- [ ] Redis URL correta
- [ ] Health check `/health` configurado
- [ ] Recursos: 1 CPU, 512 MB RAM
- [ ] Build concluído com sucesso
- [ ] Container iniciado
- [ ] Health check passando
- [ ] Endpoint `http://evo-bot-runtime:8080/health` acessível internamente

### 10. Frontend
- [ ] App `evo-frontend` criada
- [ ] Porta `80` configurada
- [ ] Domínio `evo.macip.com.br` configurado
- [ ] Source GitHub conectado
- [ ] **Build Args configurados corretamente** (CRÍTICO!)
  - `VITE_API_URL=https://api.macip.com.br`
  - `VITE_AUTH_API_URL=https://auth.macip.com.br`
  - `VITE_EVOAI_API_URL=https://core.macip.com.br`
  - `VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br`
- [ ] Variáveis runtime configuradas
- [ ] Health check `/health` configurado
- [ ] Recursos: 0.5 CPU, 256 MB RAM
- [ ] Build concluído com sucesso
- [ ] Container iniciado
- [ ] Health check passando
- [ ] HTTPS/TLS habilitado
- [ ] Site `https://evo.macip.com.br` acessível

---

## 📋 Fase 3: Verificação e Testes

### Health Checks
- [ ] `curl https://auth.macip.com.br/health` retorna 200
- [ ] `curl https://api.macip.com.br/health/live` retorna 200
- [ ] `curl https://core.macip.com.br/health` retorna 200
- [ ] `curl https://processor.macip.com.br/health` retorna 200
- [ ] `curl https://bot.macip.com.br/health` retorna 200 (se exposto)
- [ ] Frontend carrega sem erros no browser

### Teste de Autenticação
- [ ] Acessar `https://evo.macip.com.br`
- [ ] Página de login carrega
- [ ] Login com credenciais padrão funciona
- [ ] Token JWT recebido
- [ ] Redirecionamento para dashboard funciona
- [ ] Dados do usuário carregam

### Teste de API
```bash
# Login via API
- [ ] POST https://auth.macip.com.br/api/v1/auth/login funciona
- [ ] Token recebido no response
- [ ] GET https://auth.macip.com.br/api/v1/auth/me com token funciona
- [ ] Dados do usuário retornados
```

### Teste de Funcionalidades
- [ ] Criar nova conversa funciona
- [ ] Enviar mensagem funciona
- [ ] Receber mensagem funciona
- [ ] Notificações em tempo real funcionam (WebSocket)
- [ ] Criar contato funciona
- [ ] Criar agente funciona (no Core)
- [ ] Agente responde mensagens

### Teste de Workers
- [ ] Jobs do Auth Sidekiq processando
- [ ] Jobs do CRM Sidekiq processando
- [ ] Filas do Redis sendo consumidas
- [ ] Emails sendo enviados (se configurado)

### Teste de Logs
- [ ] Logs do Auth sem erros críticos
- [ ] Logs do CRM sem erros críticos
- [ ] Logs do Core sem erros críticos
- [ ] Logs do Processor sem erros críticos
- [ ] Logs do Bot Runtime sem erros críticos
- [ ] Logs do Frontend sem erros (browser console)

---

## 📋 Fase 4: Segurança

### Secrets
- [ ] Todos os secrets rotacionados (não usar defaults)
- [ ] Secrets diferentes de desenvolvimento
- [ ] Secrets salvos em password manager
- [ ] Secrets não commitados no Git
- [ ] Variáveis de ambiente não expostas publicamente

### HTTPS/TLS
- [ ] Todos os domínios públicos com HTTPS
- [ ] Certificados válidos
- [ ] Redirecionamento HTTP → HTTPS ativo
- [ ] HSTS habilitado (opcional)

### CORS
- [ ] CORS configurado no CRM
- [ ] Apenas domínios permitidos listados
- [ ] Wildcard (*) não usado em produção

### Database
- [ ] PostgreSQL com senha forte
- [ ] Acesso restrito (não público)
- [ ] SSL habilitado (opcional)
- [ ] Backup configurado

### Redis
- [ ] Redis com senha
- [ ] Acesso restrito (apenas interno)
- [ ] Persistência habilitada

---

## 📋 Fase 5: Backup e Monitoramento

### Backup
- [ ] Backup automático do PostgreSQL configurado
- [ ] Frequência: diário
- [ ] Retenção: 30 dias
- [ ] Backup testado (restore funciona)
- [ ] Backup do Redis configurado (snapshot)
- [ ] Volumes com backup habilitado

### Monitoramento
- [ ] Alertas de CPU > 80% configurados
- [ ] Alertas de RAM > 90% configurados
- [ ] Alertas de Disco > 85% configurados
- [ ] Alertas de restart loop configurados
- [ ] Alertas de health check falhando configurados
- [ ] Logs centralizados acessíveis

### Métricas
- [ ] Dashboard de métricas configurado
- [ ] CPU usage visível
- [ ] Memory usage visível
- [ ] Disk usage visível
- [ ] Response time visível
- [ ] Error rate visível

---

## 📋 Fase 6: Documentação

### Documentação Interna
- [ ] Credenciais documentadas (em local seguro)
- [ ] Arquitetura documentada
- [ ] Procedimentos de deploy documentados
- [ ] Procedimentos de rollback documentados
- [ ] Contatos de emergência documentados

### Runbooks
- [ ] Runbook de troubleshooting criado
- [ ] Runbook de backup/restore criado
- [ ] Runbook de scaling criado
- [ ] Runbook de atualização criado

---

## 📋 Fase 7: Go-Live

### Pré-Go-Live
- [ ] Todos os testes passando
- [ ] Todos os serviços healthy
- [ ] Backup testado
- [ ] Rollback plan definido
- [ ] Equipe treinada
- [ ] Documentação completa

### Go-Live
- [ ] Janela de manutenção agendada
- [ ] Comunicação enviada aos usuários
- [ ] DNS atualizado (se necessário)
- [ ] Smoke tests executados
- [ ] Monitoramento ativo
- [ ] Equipe de plantão disponível

### Pós-Go-Live
- [ ] Monitoramento por 24h
- [ ] Logs revisados
- [ ] Performance verificada
- [ ] Usuários conseguem acessar
- [ ] Funcionalidades principais testadas
- [ ] Nenhum erro crítico reportado

---

## 📋 Checklist de Troubleshooting

### Se algo der errado:

#### Serviço não inicia
- [ ] Verificar logs do container
- [ ] Verificar variáveis de ambiente
- [ ] Testar conexão com PostgreSQL
- [ ] Testar conexão com Redis
- [ ] Verificar dependências (ordem de start)
- [ ] Verificar recursos (CPU/RAM suficientes)

#### Login não funciona
- [ ] Verificar se Auth Service está healthy
- [ ] Verificar se seed foi executado
- [ ] Verificar JWT_SECRET_KEY igual em todos os serviços
- [ ] Verificar CORS no backend
- [ ] Verificar logs do Auth Service

#### Frontend não carrega
- [ ] Verificar build args do Vite
- [ ] Verificar CORS no backend
- [ ] Verificar console do browser
- [ ] Verificar se todos os serviços estão healthy
- [ ] Verificar URLs públicas corretas

#### Serviços não se comunicam
- [ ] Verificar DNS interno do EasyPanel
- [ ] Verificar URLs internas (http://service-name:port)
- [ ] Verificar se serviços estão na mesma rede
- [ ] Testar ping entre containers
- [ ] Verificar logs de conexão

---

## 🎯 Resumo Final

### Serviços Deployados
- [ ] 1. Redis
- [ ] 2. Auth Service
- [ ] 3. Auth Sidekiq
- [ ] 4. CRM Service
- [ ] 5. CRM Sidekiq
- [ ] 6. Core Service
- [ ] 7. Processor Service
- [ ] 8. Bot Runtime
- [ ] 9. Frontend

### Total de Recursos
- [ ] CPU: ~9.5 cores
- [ ] RAM: ~9 GB
- [ ] Storage: ~30 GB

### Status Geral
- [ ] ✅ Todos os serviços healthy
- [ ] ✅ Todos os testes passando
- [ ] ✅ Backup configurado
- [ ] ✅ Monitoramento ativo
- [ ] ✅ Documentação completa
- [ ] ✅ Equipe treinada

---

## 📞 Suporte

Se precisar de ajuda:
1. Consultar `DOCUMENTACAO-LOCAL-EASYPANEL.md` (documentação completa)
2. Consultar `EASYPANEL-QUICK-START.md` (guia rápido)
3. Consultar `ARQUITETURA-EASYPANEL.md` (arquitetura detalhada)
4. Verificar logs dos containers
5. Abrir issue no GitHub

---

**Data do Deploy:** ___/___/______  
**Responsável:** _________________  
**Status:** [ ] Em Progresso [ ] Concluído [ ] Com Problemas

---

**Última atualização:** 2025-04-20  
**Versão:** 1.0
