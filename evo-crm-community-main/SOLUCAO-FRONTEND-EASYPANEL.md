# ✅ Solução: Frontend no EasyPanel

**Problema:** Frontend mostra "Service is not reachable" (502)  
**Causa:** Variáveis de ambiente não estão sendo aplicadas corretamente

---

## 🔍 Análise

Você já configurou as variáveis corretamente:
```
✅ VITE_APP_ENV=production
✅ VITE_API_URL=https://api.macip.com.br
✅ VITE_AUTH_API_URL=https://auth.macip.com.br
✅ VITE_WS_URL=https://api.macip.com.br
✅ VITE_EVOAI_API_URL=https://core.macip.com.br
✅ VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
✅ VITE_TINYMCE_API_KEY=no-api-key
```

O Dockerfile está preparado para usar essas variáveis em **runtime** através do script `docker-entrypoint.sh`.

---

## 🚀 Solução Passo a Passo

### 1️⃣ Verificar Logs do Frontend

No EasyPanel:
1. Clicar em **evo-frontend**
2. Ir em **Logs**
3. Procurar por erros

**O que procurar:**
```
❌ "Permission denied" no docker-entrypoint.sh
❌ Erros de Nginx
❌ "Address already in use"
❌ Erros de build
```

### 2️⃣ Fazer Restart (Não Rebuild)

Como as variáveis são aplicadas em **runtime**, basta fazer **restart**:

1. No **evo-frontend**, clicar no botão de **Restart** (ícone de reload)
2. Aguardar container reiniciar
3. Verificar logs durante o restart

### 3️⃣ Verificar se Container Está Rodando

Após restart, verificar:
```
✅ Status verde (running)
✅ CPU > 0% (mostra que está processando)
✅ Memória sendo usada
```

### 4️⃣ Testar Acesso

Acessar: https://evogo-evo-frontend.kub3.to.easypanel.host

**Se ainda não funcionar, ir para diagnóstico avançado abaixo.**

---

## 🔧 Diagnóstico Avançado

### Problema 1: Permissão do Script

**Sintoma:** Logs mostram "Permission denied: /docker-entrypoint.sh"

**Solução:** O Dockerfile já tem `RUN chmod +x /docker-entrypoint.sh`, mas se não funcionar:

1. Fazer **Rebuild** (não apenas restart)
2. Verificar se o build completa sem erros

### Problema 2: Porta Incorreta

**Sintoma:** Container roda mas não responde

**Solução:**
1. Ir em **Settings** → **Networking**
2. Verificar se **Port** está configurada como **80**
3. Se estiver diferente, alterar para **80**
4. Salvar e fazer restart

### Problema 3: Health Check Falhando

**Sintoma:** Container reinicia constantemente

**Solução:**
1. Ir em **Settings** → **Health Check**
2. Configurar:
   ```
   Path: /health
   Port: 80
   Interval: 30
   Timeout: 10
   ```
3. Salvar e fazer restart

### Problema 4: Memória Insuficiente

**Sintoma:** Container morre após alguns segundos

**Solução:**
1. Ir em **Settings** → **Resources**
2. Aumentar memória para pelo menos **512 MB**
3. Salvar e fazer restart

---

## 🎯 Solução Alternativa: Rebuild com Variáveis Fixas

Se o runtime replacement não funcionar, podemos modificar o Dockerfile para usar as variáveis em **build-time**.

### Modificar Dockerfile

Substituir esta seção:
```dockerfile
# Build with placeholder values that will be replaced at runtime
ENV VITE_API_URL=VITE_API_URL_PLACEHOLDER
ENV VITE_AUTH_API_URL=VITE_AUTH_API_URL_PLACEHOLDER
ENV VITE_WS_URL=VITE_WS_URL_PLACEHOLDER
ENV VITE_EVOAI_API_URL=VITE_EVOAI_API_URL_PLACEHOLDER
ENV VITE_AGENT_PROCESSOR_URL=VITE_AGENT_PROCESSOR_URL_PLACEHOLDER
```

Por:
```dockerfile
# Build with fixed values for macip.com.br
ENV VITE_APP_ENV=production
ENV VITE_API_URL=https://api.macip.com.br
ENV VITE_AUTH_API_URL=https://auth.macip.com.br
ENV VITE_WS_URL=https://api.macip.com.br
ENV VITE_EVOAI_API_URL=https://core.macip.com.br
ENV VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
ENV VITE_TINYMCE_API_KEY=no-api-key
```

E remover o entrypoint (não precisa mais):
```dockerfile
# Production stage
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

Depois fazer **Rebuild** no EasyPanel.

---

## 🔍 Verificar CORS

Mesmo que o frontend funcione, pode ter problema de CORS. Verificar se o **evo-crm** tem:

```bash
CORS_ORIGINS=https://evo.macip.com.br,https://evogo-evo-frontend.kub3.to.easypanel.host
```

**Adicionar o domínio temporário do EasyPanel também!**

---

## 📋 Checklist Final

Após aplicar as soluções:

- [ ] Frontend abre sem erro 502
- [ ] Console do browser (F12) não mostra erros
- [ ] Tela de cadastro/login aparece
- [ ] Consegue criar conta
- [ ] Consegue fazer login
- [ ] Dashboard carrega

---

## 🎯 Primeiro Acesso (EVO CRM)

Quando o frontend funcionar:

### 1. Tela de Setup
```
1. Acessar o frontend
2. Sistema mostra tela de "Criar Conta" ou "Setup"
3. Preencher:
   - Nome completo
   - Email
   - Senha (mínimo 8 caracteres)
4. Clicar em "Criar Conta"
```

### 2. Ativação (se SMTP configurado)
```
1. Verificar email
2. Clicar no link de ativação
3. Voltar para o frontend
```

### 3. Login
```
1. Usar email e senha cadastrados
2. Sistema redireciona para dashboard
3. Começar a usar o CRM
```

### ⚠️ Se SMTP não estiver configurado:

O email de ativação não chegará. Você pode:

**Opção A: Configurar SMTP**
```bash
# No evo-auth, adicionar:
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-app
MAILER_SENDER_EMAIL=noreply@macip.com.br
```

**Opção B: Ativar manualmente no banco**
```sql
-- Conectar no PostgreSQL
UPDATE users SET confirmed_at = NOW() WHERE email = 'seu-email@exemplo.com';
```

---

## 🆘 Se Nada Funcionar

### Última Solução: Testar Localmente

1. Clonar o repositório
2. Testar com Docker Compose local
3. Verificar se funciona localmente
4. Comparar configurações

### Comandos para Teste Local

```bash
# Clonar
git clone https://github.com/tonygomes-wq/evo
cd evo/evo-ai-frontend-community-main

# Build local
docker build -t evo-frontend \
  --build-arg VITE_API_URL=https://api.macip.com.br \
  --build-arg VITE_AUTH_API_URL=https://auth.macip.com.br \
  --build-arg VITE_EVOAI_API_URL=https://core.macip.com.br \
  --build-arg VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br \
  .

# Rodar local
docker run -p 8080:80 \
  -e VITE_API_URL=https://api.macip.com.br \
  -e VITE_AUTH_API_URL=https://auth.macip.com.br \
  -e VITE_WS_URL=https://api.macip.com.br \
  -e VITE_EVOAI_API_URL=https://core.macip.com.br \
  -e VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br \
  evo-frontend

# Testar
curl http://localhost:8080
```

---

## 📞 Informações Importantes

### Logs que Indicam Sucesso

```
✅ "Replacing VITE_API_URL_PLACEHOLDER with https://api.macip.com.br"
✅ "nginx: [notice] start worker processes"
✅ Sem erros de permissão
✅ Sem erros de bind
```

### Logs que Indicam Problema

```
❌ "Permission denied"
❌ "Address already in use"
❌ "Cannot find module"
❌ "ENOENT: no such file or directory"
```

---

**Status:** 🔧 Aguardando verificação de logs  
**Próximo passo:** Verificar logs do frontend e fazer restart

