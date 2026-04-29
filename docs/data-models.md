# Evo CRM — Modelos de Dados

## Banco de Dados

- **Engine**: PostgreSQL 16 (com extensão pgvector)
- **Database**: `evo_community` (compartilhado entre todos os serviços)
- **ORM (Core)**: GORM (Go)
- **ORM (Auth/CRM)**: ActiveRecord (Ruby)
- **ORM (Processor)**: SQLAlchemy (Python)

---

## Tabelas do evo-core (prefixo: `evo_core_`)

### `evo_core_agents`
Agentes de IA gerenciados pelo sistema.

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| `id` | UUID | PK, default uuid_generate_v4() | Identificador único |
| `name` | VARCHAR(255) | NOT NULL | Nome do agente |
| `description` | TEXT | | Descrição do agente |
| `type` | VARCHAR(100) | | Tipo do agente |
| `created_at` | TIMESTAMPTZ | NOT NULL | Data de criação |
| `updated_at` | TIMESTAMPTZ | NOT NULL | Data de atualização |
| ~~`account_id`~~ | ~~UUID~~ | ~~FK→accounts(id)~~ | ⚠️ **Pendente** — necessário para multi-tenancy |

**Índices:**
- `idx_evo_core_agents_pkey` — PK
- `(account_id, id)` — planejado para multi-tenancy

---

### `evo_core_custom_tools`
Ferramentas HTTP customizadas para os agentes.

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| `id` | UUID | PK | Identificador único |
| `name` | VARCHAR(255) | NOT NULL | Nome da ferramenta |
| `description` | TEXT | | Descrição |
| `url` | TEXT | NOT NULL | URL do endpoint HTTP |
| `method` | VARCHAR(10) | NOT NULL | Método HTTP (GET, POST, etc.) |
| `headers` | JSONB | | Headers HTTP da ferramenta |
| `body` | JSONB | | Body template da ferramenta |
| `created_at` | TIMESTAMPTZ | NOT NULL | Data de criação |
| `updated_at` | TIMESTAMPTZ | NOT NULL | Data de atualização |
| ~~`account_id`~~ | ~~UUID~~ | | ⚠️ **Pendente** |

---

### `evo_core_api_keys`
Chaves API criptografadas com Fernet.

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| `id` | UUID | PK | Identificador único |
| `name` | VARCHAR(255) | NOT NULL | Nome descritivo |
| `provider` | VARCHAR(100) | | Provedor da API (OpenAI, etc.) |
| `value` | TEXT | NOT NULL | Valor criptografado (Fernet) |
| `created_at` | TIMESTAMPTZ | NOT NULL | Data de criação |
| `updated_at` | TIMESTAMPTZ | NOT NULL | Data de atualização |
| ~~`account_id`~~ | ~~UUID~~ | | ⚠️ **Pendente** |

> ⚠️ O campo `value` é sempre criptografado com Fernet antes de persistir. A chave `ENCRYPTION_KEY` é compartilhada com o `evo-processor`.

---

### `evo_core_folders`
Organização de workspace por pastas.

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| `id` | UUID | PK | Identificador único |
| `name` | VARCHAR(255) | NOT NULL | Nome da pasta |
| `description` | TEXT | | Descrição |
| `parent_id` | UUID | FK→evo_core_folders(id) | Pasta pai (hierarquia) |
| `created_at` | TIMESTAMPTZ | NOT NULL | Data de criação |
| `updated_at` | TIMESTAMPTZ | NOT NULL | Data de atualização |
| ~~`account_id`~~ | ~~UUID~~ | | ⚠️ **Pendente** |

---

### `evo_core_folder_shares`
Compartilhamento de pastas entre usuários.

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| `id` | UUID | PK | Identificador único |
| `folder_id` | UUID | FK→evo_core_folders(id) | Pasta compartilhada |
| `user_id` | UUID | NOT NULL | Usuário com acesso |
| `permission` | VARCHAR(50) | | Nível de permissão |
| `created_at` | TIMESTAMPTZ | NOT NULL | Data de criação |
| ~~`account_id`~~ | ~~UUID~~ | | ⚠️ **Pendente** |

---

### `evo_core_mcp_servers`
Registro de servidores Model Context Protocol globais.

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| `id` | UUID | PK | Identificador único |
| `name` | VARCHAR(255) | NOT NULL | Nome do servidor |
| `url` | TEXT | NOT NULL | URL do servidor MCP |
| `description` | TEXT | | Descrição |
| `config` | JSONB | | Configuração extra |
| `created_at` | TIMESTAMPTZ | NOT NULL | Data de criação |
| `updated_at` | TIMESTAMPTZ | NOT NULL | Data de atualização |

---

### `evo_core_custom_mcp_servers`
Servidores MCP customizados por usuário/tenant.

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| `id` | UUID | PK | Identificador único |
| `name` | VARCHAR(255) | NOT NULL | Nome |
| `url` | TEXT | NOT NULL | URL |
| `config` | JSONB | | Configuração |
| `created_at` | TIMESTAMPTZ | NOT NULL | Data de criação |
| `updated_at` | TIMESTAMPTZ | NOT NULL | Data de atualização |
| ~~`account_id`~~ | ~~UUID~~ | | ⚠️ **Pendente** |

---

### `evo_core_agent_integrations`
Integrações externas configuradas para agentes.

| Coluna | Tipo | Constraints | Descrição |
|--------|------|-------------|-----------|
| `id` | UUID | PK | Identificador único |
| `agent_id` | UUID | FK→evo_core_agents(id) | Agente pai |
| `type` | VARCHAR(100) | | Tipo de integração |
| `config` | JSONB | | Configuração da integração |
| `created_at` | TIMESTAMPTZ | NOT NULL | Data de criação |
| `updated_at` | TIMESTAMPTZ | NOT NULL | Data de atualização |
| ~~`account_id`~~ | ~~UUID~~ | | ⚠️ **Pendente** |

---

### `evo_core_schema_community_migrations`
Controle de versão de migrações do evo-core (evita conflito com Rails).

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | BIGINT PK | ID sequencial |
| `version` | VARCHAR(255) | Versão da migração |
| `dirty` | BOOLEAN | Flag de migração com erro |

---

## Tabelas Externas Referenciadas

### `accounts` (gerenciada pelo evo-crm / Rails)

O evo-core referencia esta tabela para isolamento de dados (multi-tenancy futuro):

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | UUID | Identificador único da conta/organização |
| `name` | VARCHAR | Nome da conta |
| `status` | VARCHAR | Status: `active`, `inactive` |
| `created_at` | TIMESTAMPTZ | Data de criação |

---

## Diagrama de Relacionamentos (evo-core)

```
accounts (externo, evo-crm)
  │
  ├──(futuro FK)──► evo_core_agents
  │                    │
  │                    └──► evo_core_agent_integrations
  │
  ├──(futuro FK)──► evo_core_custom_tools
  ├──(futuro FK)──► evo_core_api_keys
  ├──(futuro FK)──► evo_core_folders
  │                    │
  │                    ├──(self-join parent_id)
  │                    └──► evo_core_folder_shares
  ├──(futuro FK)──► evo_core_custom_mcp_servers
  └──(futuro FK)──► evo_core_folder_shares

evo_core_mcp_servers  (sem FK para accounts — global)
```

---

## Migrações

**Localização**: `evo-ai-core-service-community/migrations/`  
**Ferramenta**: [golang-migrate](https://github.com/golang-migrate/migrate)  
**Formato de arquivo**: `{versão}_{nome}.up.sql` / `{versão}_{nome}.down.sql`

**Comandos:**
```bash
make migrate-up              # Aplicar migrações pendentes
make migrate-down            # Reverter última migração
make migrate-create NAME=x   # Criar novo par de arquivos
make db-reset                # Resetar banco completo (⚠️ destrutivo)
```

---

## Configuração de Conexão (evo-core)

```env
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=<senha>
DB_NAME=evo_community
DB_SSLMODE=disable

# Pool de conexões
DB_MAX_IDLE_CONNS=10
DB_MAX_OPEN_CONNS=100
DB_CONN_MAX_LIFETIME=1h
DB_CONN_MAX_IDLE_TIME=30m
```
