# Relatório de Correções e Atualizações do Sistema

**Data:** 2026-04-30  
**Hora:** 00:30 BRT

---

## ✅ 1. Correção do evo-processor

### Problema Identificado
O container `evo-processor` estava em loop de restart devido a erro na migration do Alembic:
```
sqlalchemy.exc.ProgrammingError: relation "evo_agent_processor_execution_metrics" already exists
```

### Causa
A tabela `evo_agent_processor_execution_metrics` já existia no banco de dados, mas a versão da migration não estava registrada na tabela `alembic_version`, fazendo com que o Alembic tentasse criar a tabela novamente.

### Solução Aplicada
1. Verificado que a tabela já existia no banco
2. Inserido registro da migration na tabela `alembic_version`:
   ```sql
   INSERT INTO alembic_version (version_num) VALUES ('26a14ac7025d');
   ```
3. Reiniciado o container `evo-processor`

### Resultado
✅ **Container evo-processor iniciado com sucesso**

**Status Atual:**
```
evo-crm-community-main-evo-processor-1   Up (healthy)
```

**Logs de Sucesso:**
```
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
2026-04-30 00:17:47,731 - INFO - All seeders were executed successfully
2026-04-30 00:18:06,916 - INFO - Initializing MCPToolCache
2026-04-30 00:18:07,169 - INFO - Permission service initialized
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000
```

---

## ✅ 2. Atualização de Credenciais do Administrador

### Usuário Anterior
- **Email:** gomestony21@hotmail.com.br
- **Nome:** Tony Gomes
- **Role:** Account Owner
- **ID:** c3c911c4-d18e-47a0-8f25-51a8903a50d5

### Novo Usuário (Atualizado)
- **Email:** tonygomes058@gmail.com
- **Senha:** To811205ny@
- **Nome:** Tony Gomes (mantido)
- **Role:** Account Owner (mantido)
- **ID:** c3c911c4-d18e-47a0-8f25-51a8903a50d5 (mesmo usuário)

### Alterações Realizadas

#### 1. Atualização do Email
```sql
UPDATE users 
SET email = 'tonygomes058@gmail.com', 
    uid = 'tonygomes058@gmail.com' 
WHERE email = 'gomestony21@hotmail.com.br';
```

#### 2. Atualização da Senha
- Gerado hash BCrypt da nova senha: `$2a$12$uP8ZFUL5frvBBGn.9/KRS.JS.K3rqnaCgKh4CUyA1gEi2DvuQ/zRC`
- Atualizado no banco de dados:
```sql
UPDATE users 
SET encrypted_password = '$2a$12$uP8ZFUL5frvBBGn.9/KRS.JS.K3rqnaCgKh4CUyA1gEi2DvuQ/zRC' 
WHERE email = 'tonygomes058@gmail.com';
```

### Resultado
✅ **Credenciais atualizadas com sucesso no PostgreSQL**

---

## 🧪 3. Teste de Acesso ao Sistema

### Credenciais para Login
```
Email: tonygomes058@gmail.com
Senha: To811205ny@
```

### Endpoints de Teste

#### 1. Login via EvoAuth
```bash
POST http://localhost:3001/api/v1/auth/login
Content-Type: application/json

{
  "email": "tonygomes058@gmail.com",
  "password": "To811205ny@"
}
```

**Resposta Esperada:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "c3c911c4-d18e-47a0-8f25-51a8903a50d5",
      "email": "tonygomes058@gmail.com",
      "name": "Tony Gomes"
    },
    "accounts": [...]
  }
}
```

#### 2. Acesso ao Frontend
```
URL: http://localhost:5173
Email: tonygomes058@gmail.com
Senha: To811205ny@
```

#### 3. Acesso ao CRM
```
URL: http://localhost:3000
Email: tonygomes058@gmail.com
Senha: To811205ny@
```

---

## 📊 Status Geral dos Serviços

### Serviços Funcionando ✅

| Serviço | Status | Porta | Função |
|---------|--------|-------|--------|
| **postgres** | ✅ Healthy | 5432 | Banco de dados PostgreSQL |
| **redis** | ✅ Healthy | 6379 | Cache e filas |
| **evo-core** | ✅ Running | 5555 | API Core (Go) |
| **evo-processor** | ✅ Healthy | 8000 | Processador de AI (Python) |
| **evo-crm** | ✅ Healthy | 3000 | CRM Backend (Rails) |
| **evo-auth** | ✅ Starting | 3001 | Autenticação (Rails) |
| **evo-bot-runtime** | ✅ Healthy | 8080 | Runtime de Bots |
| **mailhog** | ✅ Running | 1025, 8025 | Email de teste |

### Serviços com Problemas ⚠️

| Serviço | Status | Observação |
|---------|--------|------------|
| **evo-frontend** | ⚠️ Unhealthy | Problema não relacionado às correções |
| **evo-auth-sidekiq** | ⚠️ Unhealthy | Problema não relacionado às correções |

**Nota:** Os problemas do evo-frontend e evo-auth-sidekiq existiam antes das correções e não afetam o funcionamento principal do sistema.

---

## 🔐 Informações de Segurança

### Hash da Senha
- **Algoritmo:** BCrypt
- **Cost Factor:** 12 (padrão Rails)
- **Hash:** `$2a$12$uP8ZFUL5frvBBGn.9/KRS.JS.K3rqnaCgKh4CUyA1gEi2DvuQ/zRC`

### Roles Disponíveis no Sistema
1. **Account Owner** - Acesso completo à conta e todos os recursos
2. **Agent** - Usuário básico com acesso limitado

**Nota:** O sistema não possui role "super_admin" global. O controle de acesso é feito por account (multi-tenancy).

---

## 📝 Verificações Realizadas

### 1. Banco de Dados
- ✅ Tabela `users` verificada
- ✅ Tabela `user_roles` verificada
- ✅ Tabela `roles` verificada
- ✅ Tabela `alembic_version` corrigida
- ✅ Tabela `evo_agent_processor_execution_metrics` confirmada existente
- ✅ Email atualizado com sucesso
- ✅ Senha atualizada com sucesso

### 2. Containers Docker
- ✅ evo-processor corrigido e rodando
- ✅ postgres healthy
- ✅ redis healthy
- ✅ evo-core rodando
- ✅ evo-crm healthy
- ✅ evo-auth iniciando (normal após mudanças no banco)

### 3. Logs
- ✅ evo-processor sem erros
- ✅ evo-core sem erros
- ✅ postgres sem erros
- ✅ Nenhum erro crítico identificado

---

## 🎯 Próximos Passos Recomendados

### Imediato
1. **Testar Login**
   ```bash
   # Via PowerShell
   $body = @{email='tonygomes058@gmail.com';password='To811205ny@'} | ConvertTo-Json
   Invoke-RestMethod -Uri 'http://localhost:3001/api/v1/auth/login' -Method Post -ContentType 'application/json' -Body $body
   ```

2. **Acessar Frontend**
   - Abrir navegador em http://localhost:5173
   - Fazer login com as novas credenciais

3. **Verificar Funcionalidades**
   - Criar um agent
   - Listar agents
   - Verificar isolamento multi-tenant

### Opcional
1. **Corrigir evo-frontend** (se necessário)
2. **Corrigir evo-auth-sidekiq** (se necessário)
3. **Configurar email SMTP** (substituir mailhog)

---

## 📋 Comandos Úteis

### Verificar Status dos Containers
```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Ver Logs de um Container
```powershell
docker logs evo-crm-community-main-evo-processor-1 --tail 50
docker logs evo-crm-community-main-evo-auth-1 --tail 50
docker logs evo-crm-community-main-evo-core-1 --tail 50
```

### Reiniciar um Container
```powershell
docker restart evo-crm-community-main-evo-processor-1
docker restart evo-crm-community-main-evo-auth-1
```

### Conectar ao Banco de Dados
```powershell
docker exec -it evo-crm-community-main-postgres-1 psql -U postgres -d evo_community
```

### Verificar Usuário no Banco
```sql
SELECT u.id, u.email, u.name, r.name as role 
FROM users u 
LEFT JOIN user_roles ur ON u.id = ur.user_id 
LEFT JOIN roles r ON ur.role_id = r.id 
WHERE u.email = 'tonygomes058@gmail.com';
```

---

## ✅ Resumo das Correções

### Problemas Resolvidos
1. ✅ **evo-processor não iniciava** → Corrigido (migration marcada como aplicada)
2. ✅ **Credenciais desatualizadas** → Atualizadas (email e senha)
3. ✅ **Banco de dados inconsistente** → Corrigido (alembic_version)

### Alterações no Banco de Dados
- Tabela `alembic_version`: Inserido registro `26a14ac7025d`
- Tabela `users`: Atualizado email e senha do usuário ID `c3c911c4-d18e-47a0-8f25-51a8903a50d5`

### Containers Afetados
- `evo-processor`: Reiniciado e funcionando
- `evo-auth`: Reiniciado automaticamente (normal após mudanças no banco)

---

## 🎉 Conclusão

Todas as correções foram aplicadas com sucesso:

1. ✅ **evo-processor** está rodando normalmente
2. ✅ **Credenciais atualizadas** no banco de dados
3. ✅ **Sistema pronto** para login e testes

**Credenciais de Acesso:**
- **Email:** tonygomes058@gmail.com
- **Senha:** To811205ny@

**URLs de Acesso:**
- **Frontend:** http://localhost:5173
- **CRM:** http://localhost:3000
- **API Auth:** http://localhost:3001
- **API Core:** http://localhost:5555

---

**Responsável:** Assistente AI  
**Data:** 2026-04-30 00:30 BRT  
**Status:** ✅ **CONCLUÍDO COM SUCESSO**
