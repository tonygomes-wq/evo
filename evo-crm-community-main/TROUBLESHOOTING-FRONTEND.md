# 🔧 Troubleshooting: Frontend Não Abre

**Problema:** Frontend mostra "Service is not reachable" mesmo com todos os serviços rodando (verde)

**URL:** https://evogo-evo-frontend.kub3.to.easypanel.host

---

## 🔍 Diagnóstico Inicial

### Sintomas:
- ✅ Todos os serviços estão "healthy" (verde no EasyPanel)
- ❌ Frontend retorna "Service is not reachable"
- ❌ Console do browser mostra erro: "Failed to load resource: the server responded with a status of 502"

### Possíveis Causas:

1. **Frontend não está servindo na porta correta**
2. **Build Args do Vite não foram configurados corretamente**
3. **Nginx não está configurado corretamente**
4. **Container está rodando mas não está respondendo**
5. **Health check está falhando**

---

## ✅ Checklist de Verificação

### 1. Verificar Logs do Frontend

No EasyPanel, ir em **evo-frontend** → **Logs** e procurar por:

```
❌ Erros de build
❌ Erros de start
❌ Porta incorreta
❌ Variáveis de ambiente faltando
```

**O que procurar:**
```
✅ "Server running on port 80" ou similar
✅ "Compiled successfully"
✅ Sem erros de CORS
✅ Sem erros de conexão com APIs
```

---

### 2. Verificar Build Args (CRÍTICO!)

O Frontend React/Vite precisa de **Build Args** configurados **ANTES** do build.

**No EasyPanel, ir em evo-frontend → Settings → Build:**

Verificar se os **Build Arguments** estão configurados:

```bash
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
```

**⚠️ IMPORTANTE:**
- Build Args são configurados **ANTES** do build (build-time)
- Se não foram configurados, precisa **REBUILD** completo
- Não confundir com Environment Variables (runtime)

---

### 3. Verificar Porta do Container

**No EasyPanel, ir em evo-frontend → Settings → App:**

Verificar se a **Port** está configurada corretamente:

```
Port: 80
```

**Se estiver diferente:**
- Verificar no Dockerfile qual porta o Nginx está usando
- Ajustar no EasyPanel para a porta correta

---

### 4. Verificar Dockerfile do Frontend

O Dockerfile do frontend deve:
1. Fazer build do Vite com as variáveis
2. Servir os arquivos estáticos com Nginx na porta 80

**Verificar se o Dockerfile tem:**
```dockerfile
# Build stage
FROM node:... AS builder
ARG VITE_API_URL
ARG VITE_AUTH_API_URL
# ... outros args

# Nginx stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
```

---

### 5. Verificar Health Check

**No EasyPanel, ir em evo-frontend → Settings → Health Check:**

Verificar se está configurado:
```
Path: /
Port: 80
Interval: 30s
```

**Se o health check estiver falhando:**
- Container pode estar reiniciando constantemente
- Nginx pode não estar respondendo

---

## 🔧 Soluções por Problema

### Problema 1: Build Args Não Configurados

**Sintoma:** Frontend carrega mas não consegue conectar nas APIs

**Solução:**
1. No EasyPanel, ir em **evo-frontend** → **Settings** → **Build**
2. Adicionar **Build Arguments**:
   ```
   VITE_API_URL=https://api.macip.com.br
   VITE_AUTH_API_URL=https://auth.macip.com.br
   VITE_EVOAI_API_URL=https://core.macip.com.br
   VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
   ```
3. Ir em **Actions** → **Rebuild**
4. Aguardar build completar
5. Testar novamente

---

### Problema 2: Porta Incorreta

**Sintoma:** Container rodando mas não responde

**Solução:**
1. Verificar logs do container para ver qual porta está sendo usada
2. No EasyPanel, ir em **evo-frontend** → **Settings** → **App**
3. Ajustar **Port** para a porta correta (geralmente 80 ou 3000)
4. Salvar e aguardar restart

---

### Problema 3: Nginx Não Configurado

**Sintoma:** 502 Bad Gateway ou 404

**Solução:**
Verificar se o Dockerfile tem configuração do Nginx correta.

**Criar arquivo `nginx.conf` se não existir:**
```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

---

### Problema 4: CORS Bloqueando

**Sintoma:** Frontend carrega mas APIs retornam erro CORS

**Solução:**
1. Verificar se o CRM tem CORS configurado:
   ```bash
   CORS_ORIGINS=https://evo.macip.com.br,https://evogo-evo-frontend.kub3.to.easypanel.host
   ```
2. Adicionar o domínio do EasyPanel temporário também
3. Fazer restart do CRM

---

### Problema 5: Container Reiniciando

**Sintoma:** Serviço fica verde mas depois fica vermelho

**Solução:**
1. Verificar logs para ver erro
2. Verificar se tem memória suficiente (mínimo 256 MB)
3. Verificar se o comando de start está correto

---

## 🚀 Solução Rápida (Mais Comum)

O problema mais comum é **Build Args não configurados**. Siga estes passos:

### Passo 1: Configurar Build Args

No EasyPanel:
1. Clicar em **evo-frontend**
2. Ir em **Settings** → **Build** (ou Source)
3. Procurar por **Build Arguments** ou **Build Args**
4. Adicionar:
   ```
   VITE_API_URL=https://api.macip.com.br
   VITE_AUTH_API_URL=https://auth.macip.com.br
   VITE_EVOAI_API_URL=https://core.macip.com.br
   VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
   ```

### Passo 2: Rebuild

1. Ir em **Actions** → **Rebuild**
2. Aguardar build completar (pode levar 5-10 minutos)
3. Verificar logs durante o build

### Passo 3: Verificar

1. Acessar: https://evogo-evo-frontend.kub3.to.easypanel.host
2. Abrir DevTools (F12) → Console
3. Verificar se não há erros de conexão

---

## 🔍 Como Verificar se Funcionou

### 1. Frontend Carrega
```
✅ Página abre sem erro "Service is not reachable"
✅ Mostra tela de login ou cadastro
✅ Sem erros no console do browser
```

### 2. APIs Conectam
```
✅ Console não mostra erros de CORS
✅ Console não mostra erros 404 ou 502
✅ Requisições para APIs funcionam
```

### 3. Login Funciona
```
✅ Formulário de cadastro/login aparece
✅ Consegue criar conta
✅ Consegue fazer login
```

---

## 📋 Comandos de Diagnóstico

### Testar Health Check Manualmente

```bash
# Testar frontend
curl https://evogo-evo-frontend.kub3.to.easypanel.host

# Testar APIs
curl https://auth.macip.com.br/health
curl https://api.macip.com.br/health/live
curl https://core.macip.com.br/health
curl https://processor.macip.com.br/health
```

### Verificar DNS

```bash
# Verificar se domínios resolvem
nslookup auth.macip.com.br
nslookup api.macip.com.br
nslookup core.macip.com.br
nslookup processor.macip.com.br
```

---

## 🎯 Fluxo de Primeiro Acesso (EVO CRM)

Após o frontend funcionar, o fluxo correto é:

### 1. Primeiro Acesso
```
1. Acessar: https://evogo-evo-frontend.kub3.to.easypanel.host
2. Sistema mostra tela de "Setup" ou "Cadastro"
3. Preencher dados do primeiro usuário:
   - Nome
   - Email
   - Senha
4. Clicar em "Criar Conta" ou "Setup"
```

### 2. Ativação (se necessário)
```
1. Sistema pode enviar email de ativação
2. Verificar email configurado no SMTP
3. Clicar no link de ativação
4. Fazer login
```

### 3. Login
```
1. Usar email e senha cadastrados
2. Sistema redireciona para dashboard
3. Começar a usar o CRM
```

---

## ⚠️ Problemas Conhecidos

### 1. SMTP Não Configurado
- Emails de ativação não chegam
- **Solução:** Configurar SMTP no Auth Service

### 2. Seeds Não Executados
- Banco de dados vazio
- **Solução:** Executar seeds:
  ```bash
  # No Auth Service
  bundle exec rails db:seed
  
  # No CRM Service
  bundle exec rails db:seed
  ```

### 3. Domínios Não Configurados no DNS
- URLs não resolvem
- **Solução:** Configurar registros DNS apontando para EasyPanel

---

## 📞 Próximos Passos

1. ✅ **Verificar Build Args** (mais provável)
2. ✅ **Fazer Rebuild** do frontend
3. ✅ **Verificar Logs** durante o build
4. ✅ **Testar acesso** após rebuild
5. ✅ **Verificar Console** do browser (F12)
6. ✅ **Executar Seeds** se necessário
7. ✅ **Configurar SMTP** para emails

---

## 🆘 Se Nada Funcionar

1. **Compartilhar logs completos** do frontend
2. **Verificar se Dockerfile** está correto
3. **Testar localmente** com Docker
4. **Verificar recursos** (CPU/RAM suficientes)
5. **Abrir issue** no GitHub do projeto

---

**Status:** 🔍 Diagnóstico em andamento  
**Próximo passo:** Verificar Build Args e fazer Rebuild

