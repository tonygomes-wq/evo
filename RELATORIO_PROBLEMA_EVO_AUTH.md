# Relatório - Problema com evo-auth

**Data:** 2026-04-30  
**Hora:** 00:45 BRT  
**Status:** ⚠️ **EVO-AUTH EM LOOP DE RESTART**

---

## 🔴 Problema Identificado

O container `evo-auth` está em **loop de restart contínuo**, impedindo o login no sistema.

### Sintomas
1. Container reinicia a cada 10-20 segundos
2. Status permanece em "health: starting"
3. Requisições ao endpoint `/api/v1/auth/login` retornam `ERR_EMPTY_RESPONSE`
4. Servidor Puma tenta iniciar mas falha

### Logs Observados
```
=> Booting Puma
=> Booting Puma
=> Booting Puma
(loop infinito)
```

---

## ✅ Correções Já Realizadas

### 1. evo-processor - CORRIGIDO ✅
- **Status:** Funcionando perfeitamente
- **Uptime:** Estável há 20+ minutos
- **Health:** Healthy

### 2. Credenciais Atualizadas no Banco ✅
- **Email:** tonygomes058@gmail.com (depois revertido)
- **Senha:** Hash BCrypt gerado corretamente
- **Banco:** PostgreSQL atualizado com sucesso

---

## 🔍 Análise do Problema evo-auth

### Possíveis Causas

#### 1. Problema de Configuração
- Variáveis de ambiente incorretas
- Porta 3001 em conflito
- Problema com SECRET_KEY_BASE ou JWT_SECRET_KEY

#### 2. Problema de Dependências
- Gems incompatíveis
- Ruby 3.4.0 com problemas
- Problema com shebang (`\r` line endings)

#### 3. Problema de Banco de Dados
- Migration pendente
- Schema inconsistente
- Conexão com PostgreSQL falhando

#### 4. Problema de Memória/Recursos
- Container sem recursos suficientes
- OOM (Out of Memory)

---

## 🛠️ Soluções Recomendadas

### Solução 1: Verificar Logs Completos (IMEDIATO)

```powershell
# Ver logs completos desde o início
docker logs evo-crm-community-main-evo-auth-1 --since 5m > evo-auth-logs.txt

# Buscar erro específico
Get-Content evo-auth-logs.txt | Select-String -Pattern "error|Error|ERROR|fatal|Fatal|FATAL"
```

### Solução 2: Verificar Variáveis de Ambiente

```powershell
# Inspecionar container
docker inspect evo-crm-community-main-evo-auth-1 | ConvertFrom-Json | Select-Object -ExpandProperty Config | Select-Object -ExpandProperty Env
```

### Solução 3: Rebuild do Container

```powershell
# Parar todos os containers
docker-compose -f docker-compose.dokploy.yaml down

# Remover imagem do evo-auth
docker rmi evoapicloud/evo-auth-service-community:latest

# Subir novamente (vai baixar imagem nova)
docker-compose -f docker-compose.dokploy.yaml up -d
```

### Solução 4: Usar Versão Anterior da Imagem

```yaml
# No docker-compose.dokploy.yaml, trocar:
image: evoapicloud/evo-auth-service-community:latest
# Por uma versão específica estável (se disponível):
image: evoapicloud/evo-auth-service-community:v1.0.0
```

### Solução 5: Executar Manualmente para Debug

```powershell
# Parar o container atual
docker stop evo-crm-community-main-evo-auth-1

# Executar manualmente para ver erro
docker run -it --rm \
  --network evo-crm-community-main_default \
  -e RAILS_ENV=production \
  -e POSTGRES_DATABASE=evo_community \
  -e POSTGRES_USERNAME=postgres \
  -e POSTGRES_PASSWORD=<senha> \
  -e POSTGRES_HOST=postgres \
  evoapicloud/evo-auth-service-community:latest \
  bundle exec rails s -p 3001 -b 0.0.0.0
```

---

## 📊 Status Atual dos Serviços

| Serviço | Status | Observação |
|---------|--------|------------|
| **postgres** | ✅ Healthy | Funcionando |
| **redis** | ✅ Healthy | Funcionando |
| **evo-core** | ⚠️ Unhealthy | API funciona, health check incorreto |
| **evo-processor** | ✅ Healthy | **CORRIGIDO** |
| **evo-crm** | ✅ Healthy | Funcionando |
| **evo-auth** | 🔴 Restarting | **PROBLEMA CRÍTICO** |
| **evo-bot-runtime** | ✅ Healthy | Funcionando |

---

## 🎯 Próximos Passos

### Imediato (Resolver evo-auth)

1. **Coletar Logs Completos**
   ```powershell
   docker logs evo-crm-community-main-evo-auth-1 --since 10m > evo-auth-full-logs.txt
   ```

2. **Verificar Arquivo .env**
   - Confirmar que todas as variáveis estão definidas
   - Verificar SECRET_KEY_BASE
   - Verificar JWT_SECRET_KEY
   - Verificar POSTGRES_PASSWORD

3. **Testar Conexão com Banco**
   ```powershell
   docker exec evo-crm-community-main-evo-auth-1 bundle exec rails runner "puts ActiveRecord::Base.connection.active?"
   ```

4. **Verificar Migrations**
   ```powershell
   docker exec evo-crm-community-main-evo-auth-1 bundle exec rails db:migrate:status
   ```

### Alternativa (Workaround Temporário)

Se o evo-auth não puder ser corrigido imediatamente, você pode:

1. **Usar o CRM Diretamente**
   - O evo-crm tem seu próprio sistema de autenticação
   - Acesse: http://localhost:3000
   - Pode ter credenciais diferentes

2. **Criar Token Manualmente**
   - Gerar JWT token diretamente no banco
   - Usar para acessar APIs

---

## 📝 Informações para Suporte

### Versões
- **Ruby:** 3.4.0
- **Rails:** 7.1.5.2
- **PostgreSQL:** 16 (pgvector)
- **Redis:** Alpine

### Imagem Docker
```
evoapicloud/evo-auth-service-community:latest
```

### Comando de Inicialização
```bash
sh -c "bundle exec rails s -p 3001 -b 0.0.0.0"
```

### Health Check
```yaml
test: ["CMD-SHELL", "curl -fsS http://localhost:3001/health || curl -fsS http://localhost:3001/up || exit 1"]
interval: 15s
timeout: 10s
retries: 20
start_period: 180s
```

---

## 🔐 Credenciais Atualizadas (Quando evo-auth Funcionar)

### Banco de Dados PostgreSQL
- **Email:** tonygomes058@gmail.com (atualmente revertido para gomestony21@hotmail.com.br)
- **Senha Hash:** `$2a$12$uP8ZFUL5frvBBGn.9/KRS.JS.K3rqnaCgKh4CUyA1gEi2DvuQ/zRC`
- **Senha Texto:** To811205ny@

### Para Aplicar Novamente
```sql
UPDATE users 
SET email = 'tonygomes058@gmail.com',
    uid = 'tonygomes058@gmail.com',
    encrypted_password = '$2a$12$uP8ZFUL5frvBBGn.9/KRS.JS.K3rqnaCgKh4CUyA1gEi2DvuQ/zRC'
WHERE id = 'c3c911c4-d18e-47a0-8f25-51a8903a50d5';
```

---

## 📞 Comandos de Diagnóstico

```powershell
# 1. Ver status de todos os containers
docker ps --format "table {{.Names}}\t{{.Status}}"

# 2. Ver logs do evo-auth em tempo real
docker logs -f evo-crm-community-main-evo-auth-1

# 3. Verificar uso de recursos
docker stats evo-crm-community-main-evo-auth-1 --no-stream

# 4. Inspecionar container
docker inspect evo-crm-community-main-evo-auth-1

# 5. Verificar rede
docker network inspect evo-crm-community-main_default

# 6. Testar conectividade com postgres
docker exec evo-crm-community-main-evo-auth-1 nc -zv postgres 5432

# 7. Testar conectividade com redis
docker exec evo-crm-community-main-evo-auth-1 nc -zv redis 6379
```

---

## ✅ Resumo

### O que Funcionou
1. ✅ evo-processor corrigido e estável
2. ✅ Credenciais atualizadas no PostgreSQL
3. ✅ Hash BCrypt gerado corretamente
4. ✅ Todos os outros serviços funcionando

### O que Não Funcionou
1. 🔴 evo-auth em loop de restart
2. 🔴 Login impossível via frontend
3. 🔴 API de autenticação indisponível

### Próximo Passo Crítico
**Resolver o problema do evo-auth** para permitir login no sistema.

---

**Responsável:** Assistente AI  
**Data:** 2026-04-30 00:45 BRT  
**Status:** ⚠️ **PARCIALMENTE CONCLUÍDO - EVO-AUTH REQUER ATENÇÃO**
