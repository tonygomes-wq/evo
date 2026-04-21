# 📚 Índice - Documentação de Correção dos Serviços

## Guia Completo para Resolver Problemas de Deploy

---

## 🎯 COMECE AQUI

### Para Correção Rápida (10 minutos)
👉 **[ACOES-IMEDIATAS.md](ACOES-IMEDIATAS.md)**
- Ações diretas e objetivas
- Checklist rápido
- Valores para copiar e colar
- **USE ESTE se você quer resolver AGORA**

---

## 📖 Documentação Completa

### 1. 🔧 Correção Detalhada dos Problemas
**[FIX-SERVICOS-NAO-INICIANDO.md](FIX-SERVICOS-NAO-INICIANDO.md)**
- Explicação completa de cada problema
- Causas raiz identificadas
- Soluções detalhadas com contexto
- Comandos de diagnóstico
- Ordem de execução recomendada

**Quando usar:**
- Você quer entender O QUE está errado e POR QUÊ
- Precisa de contexto sobre os erros
- Quer ver todas as opções de solução

---

### 2. 📋 Guia Passo a Passo
**[PASSO-A-PASSO-CORRECAO.md](PASSO-A-PASSO-CORRECAO.md)**
- Instruções numeradas e sequenciais
- Capturas de tela sugeridas
- Verificações após cada passo
- Troubleshooting inline
- Checklist de verificação

**Quando usar:**
- Você prefere seguir instruções passo a passo
- Quer garantir que não vai pular nenhuma etapa
- Precisa de um guia estruturado

---

### 3. 🔍 Comparação Visual de Valores
**[COMPARACAO-VALORES.md](COMPARACAO-VALORES.md)**
- Valores errados vs corretos lado a lado
- Destaque visual das diferenças
- Exemplos de erros comuns
- Template completo para copiar
- Pontos críticos de atenção

**Quando usar:**
- Você quer ver exatamente O QUE mudar
- Precisa comparar valores atuais com corretos
- Quer copiar e colar valores corretos

---

### 4. 🗄️ Comandos de Diagnóstico do Banco
**[COMANDOS-DIAGNOSTICO-BD.md](COMANDOS-DIAGNOSTICO-BD.md)**
- Queries SQL para verificação
- Comandos Rails Console
- Comandos Rails Runner
- Scripts de manutenção
- Correção de migrações

**Quando usar:**
- Você precisa diagnosticar problemas no banco
- Quer verificar se migrações foram executadas
- Precisa corrigir problemas de schema
- Quer fazer manutenção do PostgreSQL

---

## 🚀 Fluxo de Trabalho Recomendado

### Cenário 1: "Quero resolver rápido"
```
1. Ler: ACOES-IMEDIATAS.md
2. Executar as 3 ações
3. Verificar se funcionou
4. Se não funcionou → Ir para Cenário 2
```

### Cenário 2: "Preciso entender o problema"
```
1. Ler: FIX-SERVICOS-NAO-INICIANDO.md
2. Identificar qual problema você tem
3. Ler: COMPARACAO-VALORES.md
4. Aplicar correções específicas
5. Usar: COMANDOS-DIAGNOSTICO-BD.md se necessário
```

### Cenário 3: "Quero um guia detalhado"
```
1. Ler: PASSO-A-PASSO-CORRECAO.md
2. Seguir cada passo na ordem
3. Marcar checklist conforme avança
4. Usar: COMPARACAO-VALORES.md para referência
5. Usar: COMANDOS-DIAGNOSTICO-BD.md se houver erro
```

---

## 🎯 Problemas Específicos

### Problema: Senha do PostgreSQL incorreta
```
📖 Documentos relevantes:
1. ACOES-IMEDIATAS.md → Ação 1
2. COMPARACAO-VALORES.md → Seção POSTGRES_PASSWORD
3. COMANDOS-DIAGNOSTICO-BD.md → Verificar conexão

✅ Solução rápida:
Mudar POSTGRES_PASSWORD para: 355cbf3375d96724de1f
```

### Problema: Redis não autentica
```
📖 Documentos relevantes:
1. ACOES-IMEDIATAS.md → Ação 1
2. COMPARACAO-VALORES.md → Seção REDIS_URL
3. FIX-SERVICOS-NAO-INICIANDO.md → Problema 3

✅ Solução rápida:
Mudar REDIS_URL para: redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0
```

### Problema: Build path incorreto
```
📖 Documentos relevantes:
1. ACOES-IMEDIATAS.md → Ação 2
2. COMPARACAO-VALORES.md → Seção BUILD PATH
3. FIX-SERVICOS-NAO-INICIANDO.md → Problema 1

✅ Solução rápida:
Mudar Build Path para: evo-ai-crm-community-main (sem /)
```

### Problema: Erro de migração (sentiment_offensive)
```
📖 Documentos relevantes:
1. FIX-SERVICOS-NAO-INICIANDO.md → Problema 4
2. COMANDOS-DIAGNOSTICO-BD.md → Correção de migrações
3. PASSO-A-PASSO-CORRECAO.md → Passo 1.6

✅ Solução rápida:
Executar no console do evo-crm:
bundle exec rails runner "ActiveRecord::Base.connection.execute(\"INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING\")"
```

---

## 📊 Matriz de Documentos

| Documento | Objetivo | Tempo | Nível | Quando Usar |
|-----------|----------|-------|-------|-------------|
| ACOES-IMEDIATAS.md | Resolver rápido | 10min | Básico | Primeira tentativa |
| PASSO-A-PASSO-CORRECAO.md | Guia estruturado | 12min | Básico | Prefere instruções |
| COMPARACAO-VALORES.md | Referência visual | 5min | Básico | Comparar valores |
| FIX-SERVICOS-NAO-INICIANDO.md | Entender problemas | 15min | Intermediário | Quer contexto |
| COMANDOS-DIAGNOSTICO-BD.md | Diagnóstico avançado | Variável | Avançado | Problemas complexos |

---

## 🔍 Busca Rápida por Palavra-chave

### PostgreSQL
- ACOES-IMEDIATAS.md → Ação 1
- COMPARACAO-VALORES.md → Seção POSTGRES_PASSWORD
- COMANDOS-DIAGNOSTICO-BD.md → Verificações básicas

### Redis
- ACOES-IMEDIATAS.md → Ação 1
- COMPARACAO-VALORES.md → Seção REDIS_URL
- FIX-SERVICOS-NAO-INICIANDO.md → Problema 3

### Build Path
- ACOES-IMEDIATAS.md → Ação 2
- COMPARACAO-VALORES.md → Seção BUILD PATH
- FIX-SERVICOS-NAO-INICIANDO.md → Problema 1

### Migração
- PASSO-A-PASSO-CORRECAO.md → Passo 1.6
- COMANDOS-DIAGNOSTICO-BD.md → Correção de migrações
- FIX-SERVICOS-NAO-INICIANDO.md → Problema 4

### evo-crm
- Todos os documentos (problema principal)

### evo-crm-sidekiq
- ACOES-IMEDIATAS.md → Ação 2
- FIX-SERVICOS-NAO-INICIANDO.md → Problema 1 e 5
- PASSO-A-PASSO-CORRECAO.md → Passo 2

---

## 📝 Checklist Geral

Use este checklist para acompanhar seu progresso:

### Preparação
- [ ] Li ACOES-IMEDIATAS.md
- [ ] Identifiquei qual serviço está com problema
- [ ] Tenho acesso ao Easypanel
- [ ] Tenho os valores corretos anotados

### Correção evo-crm
- [ ] POSTGRES_PASSWORD corrigido
- [ ] REDIS_URL corrigido
- [ ] Serviço reiniciado
- [ ] Logs verificados
- [ ] Migração corrigida (se necessário)
- [ ] Health check OK

### Correção evo-crm-sidekiq
- [ ] Build Path corrigido
- [ ] POSTGRES_PASSWORD corrigido
- [ ] REDIS_URL corrigido
- [ ] Rebuild executado
- [ ] Build completado
- [ ] Serviço Running

### Verificação Final
- [ ] Todos os serviços Running
- [ ] Health checks OK
- [ ] Login funcionando
- [ ] Dashboard carregando
- [ ] Conversa criada
- [ ] Mensagens enviadas

---

## 🎓 Níveis de Conhecimento

### Iniciante
**Comece aqui:**
1. ACOES-IMEDIATAS.md
2. PASSO-A-PASSO-CORRECAO.md
3. COMPARACAO-VALORES.md

**Evite por enquanto:**
- COMANDOS-DIAGNOSTICO-BD.md (muito técnico)

### Intermediário
**Comece aqui:**
1. FIX-SERVICOS-NAO-INICIANDO.md
2. COMPARACAO-VALORES.md
3. PASSO-A-PASSO-CORRECAO.md

**Use quando necessário:**
- COMANDOS-DIAGNOSTICO-BD.md

### Avançado
**Comece aqui:**
1. FIX-SERVICOS-NAO-INICIANDO.md
2. COMANDOS-DIAGNOSTICO-BD.md

**Use para referência:**
- COMPARACAO-VALORES.md
- ACOES-IMEDIATAS.md

---

## 🔗 Links Rápidos

### Documentação do Projeto
- [EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md)
- [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md)
- [CHECKLIST-DEPLOY-EASYPANEL.md](evo-crm-community-main/CHECKLIST-DEPLOY-EASYPANEL.md)

### Documentação de Correção (Esta Série)
- [ACOES-IMEDIATAS.md](ACOES-IMEDIATAS.md) ⭐ **COMECE AQUI**
- [PASSO-A-PASSO-CORRECAO.md](PASSO-A-PASSO-CORRECAO.md)
- [COMPARACAO-VALORES.md](COMPARACAO-VALORES.md)
- [FIX-SERVICOS-NAO-INICIANDO.md](FIX-SERVICOS-NAO-INICIANDO.md)
- [COMANDOS-DIAGNOSTICO-BD.md](COMANDOS-DIAGNOSTICO-BD.md)

---

## 📞 Suporte

### Se você está com dúvida sobre qual documento ler:

**Pergunta:** "Quero resolver rápido, qual documento?"
**Resposta:** ACOES-IMEDIATAS.md

**Pergunta:** "Quero entender o que está errado"
**Resposta:** FIX-SERVICOS-NAO-INICIANDO.md

**Pergunta:** "Quero um guia passo a passo"
**Resposta:** PASSO-A-PASSO-CORRECAO.md

**Pergunta:** "Quero ver os valores corretos"
**Resposta:** COMPARACAO-VALORES.md

**Pergunta:** "Tenho problema no banco de dados"
**Resposta:** COMANDOS-DIAGNOSTICO-BD.md

---

## ⏱️ Estimativa de Tempo

### Leitura
- ACOES-IMEDIATAS.md: 3 minutos
- PASSO-A-PASSO-CORRECAO.md: 5 minutos
- COMPARACAO-VALORES.md: 3 minutos
- FIX-SERVICOS-NAO-INICIANDO.md: 8 minutos
- COMANDOS-DIAGNOSTICO-BD.md: 10 minutos

### Execução
- Correção evo-crm: 3-5 minutos
- Correção evo-crm-sidekiq: 3-5 minutos
- Verificação: 2 minutos
- **Total: 8-12 minutos**

---

## 🎯 Objetivo Final

Após seguir esta documentação, você deve ter:

✅ Todos os 8 serviços Running no Easypanel
✅ Health checks retornando OK
✅ Login funcionando no frontend
✅ Dashboard carregando corretamente
✅ Conversas sendo criadas
✅ Mensagens sendo enviadas e recebidas
✅ Agentes respondendo

---

## 📊 Status Atual vs Desejado

### Status Atual (Antes da Correção)
```
✅ evo-auth: RUNNING
✅ evo-auth-sidekiq: RUNNING
✅ evo-bot-runtime: RUNNING
✅ evo-core: RUNNING
✅ evo-frontend: RUNNING
✅ evo-processor: RUNNING
❌ evo-crm: FAILED (senha PostgreSQL + Redis + migração)
❌ evo-crm-sidekiq: BUILD FAILED (build path)
```

### Status Desejado (Após a Correção)
```
✅ evo-auth: RUNNING
✅ evo-auth-sidekiq: RUNNING
✅ evo-bot-runtime: RUNNING
✅ evo-core: RUNNING
✅ evo-frontend: RUNNING
✅ evo-processor: RUNNING
✅ evo-crm: RUNNING ← CORRIGIDO
✅ evo-crm-sidekiq: RUNNING ← CORRIGIDO
```

---

## 🚀 Próximos Passos Após Correção

1. ✅ Fazer backup do banco de dados
2. ✅ Documentar configurações finais
3. ✅ Configurar monitoramento
4. ✅ Configurar alertas
5. ✅ Testar integrações
6. ✅ Configurar backup automático

---

**Última atualização:** 21/04/2026
**Versão:** 1.0
**Autor:** Kiro AI Assistant
**Status:** Pronto para uso

---

## 📌 Nota Importante

Esta documentação foi criada especificamente para resolver os problemas identificados no deploy do EVO CRM Community no Easypanel. Os valores e configurações são específicos para este ambiente.

**Não compartilhe os valores de senhas e tokens fora do ambiente seguro!**

---

**⭐ RECOMENDAÇÃO: Comece por [ACOES-IMEDIATAS.md](ACOES-IMEDIATAS.md)**
