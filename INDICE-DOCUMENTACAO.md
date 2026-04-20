# 📚 Índice Completo da Documentação - EVO CRM Community

**Repositório:** https://github.com/tonygomes-wq/evo

---

## 🎯 Por Onde Começar?

### Você é...

#### 👨‍💻 Desenvolvedor (Ambiente Local)
1. Ler: [README.md](README.md)
2. Seguir: [Makefile](evo-crm-community-main/Makefile) - comandos `make setup` e `make start`
3. Consultar: [COMANDOS-UTEIS.md](evo-crm-community-main/COMANDOS-UTEIS.md)

#### 🚀 DevOps (Deploy no EasyPanel)
1. Ler: [RESUMO-EXECUTIVO.md](RESUMO-EXECUTIVO.md)
2. Seguir: [EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md)
3. Usar: [CHECKLIST-DEPLOY-EASYPANEL.md](evo-crm-community-main/CHECKLIST-DEPLOY-EASYPANEL.md)

#### 🏗️ Arquiteto (Entender a Arquitetura)
1. Ler: [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md)
2. Consultar: [DOCUMENTACAO-LOCAL-EASYPANEL.md](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md)
3. Revisar: READMEs de cada serviço

#### 📊 Gestor (Visão Geral)
1. Ler: [RESUMO-EXECUTIVO.md](RESUMO-EXECUTIVO.md)
2. Revisar: [README.md](README.md)

---

## 📖 Documentação Principal

### 🌟 Essenciais (Leitura Obrigatória)

| Documento | Descrição | Público | Tempo |
|-----------|-----------|---------|-------|
| **[README.md](README.md)** | Visão geral do projeto | Todos | 5 min |
| **[RESUMO-EXECUTIVO.md](RESUMO-EXECUTIVO.md)** | Análise de viabilidade e plano | Gestores/DevOps | 10 min |
| **[EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md)** | Guia rápido de deploy | DevOps | 30 min |

### 📚 Documentação Completa

| Documento | Descrição | Público | Tempo |
|-----------|-----------|---------|-------|
| **[DOCUMENTACAO-LOCAL-EASYPANEL.md](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md)** | Documentação completa e detalhada | DevOps/Desenvolvedores | 1-2 horas |
| **[ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md)** | Diagramas e arquitetura visual | Arquitetos/DevOps | 30 min |
| **[CHECKLIST-DEPLOY-EASYPANEL.md](evo-crm-community-main/CHECKLIST-DEPLOY-EASYPANEL.md)** | Checklist interativo de deploy | DevOps | Durante deploy |
| **[COMANDOS-UTEIS.md](evo-crm-community-main/COMANDOS-UTEIS.md)** | Referência rápida de comandos | Desenvolvedores/DevOps | Consulta |

### 📋 Templates e Configuração

| Arquivo | Descrição | Uso |
|---------|-----------|-----|
| **[.env.easypanel.template](evo-crm-community-main/.env.easypanel.template)** | Template de variáveis de ambiente | Copiar e preencher |
| **[.env.example](evo-crm-community-main/.env.example)** | Exemplo para ambiente local | Referência |
| **[docker-compose.yml](evo-crm-community-main/docker-compose.yml)** | Orquestração Docker | Desenvolvimento local |
| **[Makefile](evo-crm-community-main/Makefile)** | Comandos automatizados | Desenvolvimento local |

---

## 🔧 Documentação por Serviço

### Auth Service (Ruby/Rails)
- **[README.md](evo-auth-service-community-main/README.md)** - Documentação completa
- **[Dockerfile](evo-auth-service-community-main/Dockerfile)** - Build do container
- **[.env.example](evo-auth-service-community-main/.env.example)** - Variáveis de ambiente

### CRM Service (Ruby/Rails)
- **[README.md](evo-crm-community-main/README.md)** - Documentação completa
- **[Dockerfile](evo-crm-community-main/evo-ai-crm-community/docker/Dockerfile)** - Build do container
- **[.env.example](evo-crm-community-main/.env.example)** - Variáveis de ambiente

### Core Service (Go)
- **[README.md](evo-ai-core-service-community-main/README.md)** - Documentação completa
- **[Dockerfile](evo-ai-core-service-community-main/Dockerfile)** - Build do container
- **[.env.example](evo-ai-core-service-community-main/.env.example)** - Variáveis de ambiente

### Processor Service (Python)
- **[README.md](evo-ai-processor-community-main/README.md)** - Documentação completa
- **[Dockerfile](evo-ai-processor-community-main/Dockerfile)** - Build do container
- **[.env.example](evo-ai-processor-community-main/.env.example)** - Variáveis de ambiente

### Bot Runtime (Go)
- Dockerfile e configuração básica
- Sem README específico (documentação no projeto principal)

### Frontend (React)
- **[README.md](evo-ai-frontend-community-main/README.md)** - Documentação completa
- **[Dockerfile](evo-ai-frontend-community-main/Dockerfile)** - Build do container
- **[.env.example](evo-ai-frontend-community-main/.env.example)** - Variáveis de ambiente

---

## 📊 Fluxo de Leitura Recomendado

### Para Deploy no EasyPanel (Primeira Vez)

```
1. README.md (5 min)
   ↓
2. RESUMO-EXECUTIVO.md (10 min)
   ↓
3. EASYPANEL-QUICK-START.md (30 min)
   ↓
4. .env.easypanel.template (preencher)
   ↓
5. CHECKLIST-DEPLOY-EASYPANEL.md (durante deploy)
   ↓
6. COMANDOS-UTEIS.md (consulta quando necessário)
```

### Para Entender a Arquitetura

```
1. README.md (5 min)
   ↓
2. ARQUITETURA-EASYPANEL.md (30 min)
   ↓
3. DOCUMENTACAO-LOCAL-EASYPANEL.md (1-2 horas)
   ↓
4. READMEs de cada serviço (conforme necessário)
```

### Para Desenvolvimento Local

```
1. README.md (5 min)
   ↓
2. Makefile (ver comandos disponíveis)
   ↓
3. make setup (executar)
   ↓
4. COMANDOS-UTEIS.md (consulta)
   ↓
5. READMEs de serviços específicos (conforme necessário)
```

---

## 🎯 Documentação por Objetivo

### Objetivo: Fazer Deploy no EasyPanel

**Documentos necessários:**
1. ✅ [EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md)
2. ✅ [.env.easypanel.template](evo-crm-community-main/.env.easypanel.template)
3. ✅ [CHECKLIST-DEPLOY-EASYPANEL.md](evo-crm-community-main/CHECKLIST-DEPLOY-EASYPANEL.md)

**Documentos opcionais:**
- [DOCUMENTACAO-LOCAL-EASYPANEL.md](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md) - Para troubleshooting
- [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md) - Para entender melhor

### Objetivo: Rodar Localmente

**Documentos necessários:**
1. ✅ [README.md](README.md)
2. ✅ [Makefile](evo-crm-community-main/Makefile)
3. ✅ [.env.example](evo-crm-community-main/.env.example)

**Documentos opcionais:**
- [COMANDOS-UTEIS.md](evo-crm-community-main/COMANDOS-UTEIS.md) - Comandos úteis
- READMEs de cada serviço - Para desenvolvimento específico

### Objetivo: Entender a Arquitetura

**Documentos necessários:**
1. ✅ [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md)
2. ✅ [DOCUMENTACAO-LOCAL-EASYPANEL.md](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md)

**Documentos opcionais:**
- READMEs de cada serviço - Para detalhes técnicos

### Objetivo: Troubleshooting

**Documentos necessários:**
1. ✅ [DOCUMENTACAO-LOCAL-EASYPANEL.md](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md) - Seção de troubleshooting
2. ✅ [COMANDOS-UTEIS.md](evo-crm-community-main/COMANDOS-UTEIS.md) - Comandos de diagnóstico

**Documentos opcionais:**
- [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md) - Para entender fluxos

### Objetivo: Apresentar o Projeto

**Documentos necessários:**
1. ✅ [RESUMO-EXECUTIVO.md](RESUMO-EXECUTIVO.md)
2. ✅ [README.md](README.md)

**Documentos opcionais:**
- [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md) - Diagramas visuais

---

## 🔍 Busca Rápida

### Procurando por...

#### "Como gerar secrets?"
→ [EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md) - Passo 1  
→ [COMANDOS-UTEIS.md](evo-crm-community-main/COMANDOS-UTEIS.md) - Seção "Gerar Secrets"

#### "Quais variáveis de ambiente preciso?"
→ [.env.easypanel.template](evo-crm-community-main/.env.easypanel.template)  
→ [DOCUMENTACAO-LOCAL-EASYPANEL.md](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md) - Seção "Matriz de Variáveis"

#### "Qual a ordem de deploy?"
→ [EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md) - Passo 4  
→ [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md) - Seção "Dependências"

#### "Como fazer backup?"
→ [COMANDOS-UTEIS.md](evo-crm-community-main/COMANDOS-UTEIS.md) - Seção "PostgreSQL"  
→ [DOCUMENTACAO-LOCAL-EASYPANEL.md](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md) - Fase 5

#### "Serviço não inicia, o que fazer?"
→ [DOCUMENTACAO-LOCAL-EASYPANEL.md](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md) - Seção "Troubleshooting"  
→ [COMANDOS-UTEIS.md](evo-crm-community-main/COMANDOS-UTEIS.md) - Seção "Troubleshooting"

#### "Como testar se está funcionando?"
→ [CHECKLIST-DEPLOY-EASYPANEL.md](evo-crm-community-main/CHECKLIST-DEPLOY-EASYPANEL.md) - Fase 3  
→ [COMANDOS-UTEIS.md](evo-crm-community-main/COMANDOS-UTEIS.md) - Seção "Monitoramento"

#### "Quais recursos preciso?"
→ [RESUMO-EXECUTIVO.md](RESUMO-EXECUTIVO.md) - Seção "Componentes"  
→ [EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md) - Tabela de recursos

#### "Como funciona a arquitetura?"
→ [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md)  
→ [README.md](README.md) - Seção "Arquitetura"

---

## 📱 Acesso Rápido por Tipo

### 📖 Guias
- [README.md](README.md) - Visão geral
- [EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md) - Deploy rápido
- [DOCUMENTACAO-LOCAL-EASYPANEL.md](evo-crm-community-main/DOCUMENTACAO-LOCAL-EASYPANEL.md) - Documentação completa

### 🏗️ Arquitetura
- [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md) - Diagramas e fluxos
- [RESUMO-EXECUTIVO.md](RESUMO-EXECUTIVO.md) - Visão executiva

### ✅ Checklists
- [CHECKLIST-DEPLOY-EASYPANEL.md](evo-crm-community-main/CHECKLIST-DEPLOY-EASYPANEL.md) - Deploy completo

### 📋 Templates
- [.env.easypanel.template](evo-crm-community-main/.env.easypanel.template) - Variáveis de ambiente
- [.env.example](evo-crm-community-main/.env.example) - Exemplo local

### 🛠️ Referência
- [COMANDOS-UTEIS.md](evo-crm-community-main/COMANDOS-UTEIS.md) - Comandos úteis
- [Makefile](evo-crm-community-main/Makefile) - Automação local

### 🐳 Docker
- [docker-compose.yml](evo-crm-community-main/docker-compose.yml) - Orquestração
- Dockerfiles de cada serviço

---

## 📞 Suporte

### Documentação
- 📚 Todos os documentos listados acima
- 🔍 Use Ctrl+F para buscar em cada documento

### Comunidade
- 🐛 [Issues](https://github.com/tonygomes-wq/evo/issues)
- 💬 [Discussions](https://github.com/tonygomes-wq/evo/discussions)

### Contato
- 📧 Email: contato@evolution-api.com
- 🌐 Website: https://evolution-api.com

---

## 📊 Estatísticas da Documentação

### Total de Documentos
- **Guias principais:** 4
- **Documentação técnica:** 4
- **Templates:** 2
- **READMEs de serviços:** 6
- **Total:** 16+ documentos

### Cobertura
- ✅ Setup inicial: 100%
- ✅ Deploy EasyPanel: 100%
- ✅ Desenvolvimento local: 100%
- ✅ Troubleshooting: 100%
- ✅ Arquitetura: 100%
- ✅ Comandos úteis: 100%

### Tempo de Leitura Estimado
- **Mínimo (quick start):** 45 minutos
- **Completo (tudo):** 4-6 horas
- **Referência (consulta):** Conforme necessário

---

## 🎓 Recomendações de Leitura

### Para Iniciantes
1. Começar pelo [README.md](README.md)
2. Seguir o [EASYPANEL-QUICK-START.md](evo-crm-community-main/EASYPANEL-QUICK-START.md)
3. Usar o [CHECKLIST-DEPLOY-EASYPANEL.md](evo-crm-community-main/CHECKLIST-DEPLOY-EASYPANEL.md)

### Para Experientes
1. Revisar [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md)
2. Consultar [.env.easypanel.template](evo-crm-community-main/.env.easypanel.template)
3. Usar [COMANDOS-UTEIS.md](evo-crm-community-main/COMANDOS-UTEIS.md) como referência

### Para Gestores
1. Ler [RESUMO-EXECUTIVO.md](RESUMO-EXECUTIVO.md)
2. Revisar [README.md](README.md)
3. Consultar [ARQUITETURA-EASYPANEL.md](evo-crm-community-main/ARQUITETURA-EASYPANEL.md) para apresentações

---

**Última atualização:** 2025-04-20  
**Versão:** 1.0  
**Repositório:** https://github.com/tonygomes-wq/evo
