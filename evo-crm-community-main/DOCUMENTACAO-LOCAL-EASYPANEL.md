# EVO CRM Community - Documentacao de subida local e plano EasyPanel

## 1) Objetivo

Este documento registra:

- o que foi feito para subir o projeto localmente no Windows com Docker Desktop;
- os ajustes tecnicos aplicados para contornar erros de bootstrap;
- um plano futuro para publicar a stack no EasyPanel com foco em estabilidade e operacao.

---

## 2) Contexto da stack

Servicos principais da stack no `docker-compose.yml`:

- `postgres` (porta 5432)
- `redis` (porta 6379)
- `mailhog` (portas 1025 e 8025)
- `evo-auth` (porta 3001)
- `evo-crm` (porta 3000)
- `evo-core` (porta 5555)
- `evo-processor` (porta 8000)
- `evo-bot-runtime` (porta 8080)
- `evo-frontend` (porta 5173)

---

## 3) O que foi feito para subir localmente

### 3.1 Preparacao inicial

1. Confirmada a estrutura do projeto e o compose principal em:
   - `docker-compose.yml`
2. Criado arquivo de ambiente local:
   - copiado `.env.example` para `.env`.

### 3.2 Correcao de repositorios vazios na pasta raiz

Foi identificado que as pastas de servicos dentro de `evo-crm-community-main` estavam vazias (sem codigo), o que impedia o build do Docker.

Acao executada:

- clonagem dos repositorios dos servicos diretamente nas pastas esperadas pelo compose:
  - `evo-auth-service-community`
  - `evo-ai-crm-community`
  - `evo-ai-frontend-community`
  - `evo-ai-processor-community`
  - `evo-ai-core-service-community`
  - `evo-bot-runtime`

### 3.3 Correcao de variaveis no `.env`

Foi detectado warning recorrente de interpolacao no Docker Compose por causa de caractere `$` em secrets.

Ajustes aplicados:

- valores de `SECRET_KEY_BASE`, `JWT_SECRET_KEY` e `DOORKEEPER_JWT_SECRET_KEY` ajustados para strings sem `$`.

### 3.4 Correcao de line ending em scripts shell

No Windows, varios scripts `.sh` estavam com CRLF e causavam erros como:

- `exec ...: no such file or directory`

Acao executada:

- normalizacao para LF de scripts nos servicos:
  - CRM
  - Core
  - Auth
  - Processor
  - Bot Runtime
  - Frontend

### 3.5 Correcao de healthcheck no Core

Foi identificado que o endpoint configurado no compose para o `evo-core` retornava 404.

Ajuste aplicado em `docker-compose.yml`:

- de `http://localhost:5555/api/v1/health`
- para `http://localhost:5555/health`

### 3.6 Bootstrap de banco e migrations

Durante o bootstrap houve inconsistencias de migrations:

- no `evo-processor`: erro de `DuplicateTableError` em migration Alembic;
- no `evo-crm`: pending migrations e conflitos de colunas em parte da sequencia.

Acoes de contorno aplicadas para ambiente local:

- `docker compose down -v --remove-orphans` para reset de volumes;
- ajuste de `alembic_version` no PostgreSQL para alinhar estado inicial do processor;
- execucao de `rails db:prepare` no container do CRM;
- insercao de versoes em `schema_migrations` para alinhar o estado esperado no bootstrap local.

---

## 4) Resultado atual (ambiente local)

Stack funcional com endpoints principais acessiveis:

- Frontend: `http://localhost:5173`
- CRM: `http://localhost:3000`
- Auth: `http://localhost:3001`
- Core: `http://localhost:5555`
- Processor: `http://localhost:8000`
- Mailhog: `http://localhost:8025`

Observacao:

- `evo-auth-sidekiq` pode aparecer como `unhealthy` em alguns ciclos de healthcheck, mas em geral o processo esta ativo.

---

## 5) Comandos operacionais locais

Na raiz `evo-crm-community-main`:

- subir stack:
  - `docker compose up -d`
- verificar status:
  - `docker compose ps`
- acompanhar logs:
  - `docker compose logs -f`
- reiniciar servico especifico:
  - `docker compose restart <servico>`
- parar stack:
  - `docker compose down`
- reset completo (dados locais):
  - `docker compose down -v --remove-orphans`

---

## 6) Plano futuro para subir no EasyPanel

## Fase 0 - Preparacao (obrigatoria)

- padronizar build/deploy dos servicos via imagem Docker versionada (tag semantica e `latest` controlada);
- remover dependencia de ajustes manuais de migrations;
- revisar healthchecks de todos os servicos para endpoints reais;
- congelar estrategia de persistencia:
  - Postgres e Redis com volumes gerenciados no EasyPanel.

Entregaveis:

- compose/projeto de deploy sem hacks locais;
- checklist de variaveis de ambiente por servico.

## Fase 1 - Ambiente de homologacao (staging) no EasyPanel

- criar projeto no EasyPanel;
- provisionar:
  - banco Postgres gerenciado;
  - Redis gerenciado;
  - aplicacoes: Auth, CRM, Core, Processor, Bot Runtime, Frontend;
- configurar dominio staging e TLS;
- configurar variaveis de ambiente seguras (sem defaults de dev);
- executar migrations controladas por pipeline de deploy.

Criticos desta fase:

- ordem de inicializacao entre servicos;
- conectividade interna por DNS de servico;
- politicas de restart e limites de recursos.

## Fase 2 - Observabilidade e operacao

- logs centralizados;
- metricas basicas:
  - uso de CPU/RAM por servico;
  - taxa de erro HTTP 5xx;
  - disponibilidade por healthcheck;
- alertas:
  - container reiniciando em loop;
  - indisponibilidade de banco/redis;
  - falha de migration.

## Fase 3 - Seguranca e producao

- rotacionar todos os segredos;
- separar variaveis por ambiente (`dev`, `staging`, `prod`);
- configurar backup automatico de Postgres;
- validar restore de backup (teste real);
- aplicar politicas de acesso (usuarios/equipes do EasyPanel);
- revisar CORS e URL publica de frontend/API.

## Fase 4 - Go-live

- janela de corte e checklist final;
- deploy progressivo;
- smoke tests pos-deploy:
  - login;
  - criacao de conversa;
  - fluxo de agente/processador;
  - jobs em sidekiq;
- plano de rollback com imagem/tag anterior.

---

## 7) Riscos conhecidos e mitigacao

- **Risco:** divergencia entre estado de migration e esquema do banco.  
  **Mitigacao:** migration runner unico por ambiente + backup antes de migrar.

- **Risco:** falhas por CRLF em scripts shell em pipeline Windows.  
  **Mitigacao:** enforcement de LF com `.gitattributes`.

- **Risco:** healthcheck apontando para endpoint incorreto.  
  **Mitigacao:** teste automatizado de health endpoints em CI.

- **Risco:** secrets de desenvolvimento em producao.  
  **Mitigacao:** vault/secret manager + rotacao periodica.

---

## 8) Proximos passos recomendados

1. Criar `.gitattributes` para forcar `*.sh` com LF.
2. Definir pipeline CI/CD para build e publicacao de imagens.
3. Criar compose/stack de `staging` especifico para EasyPanel.
4. Documentar matriz final de variaveis de ambiente por servico.
5. Executar primeiro deploy em staging com teste de ponta a ponta.
