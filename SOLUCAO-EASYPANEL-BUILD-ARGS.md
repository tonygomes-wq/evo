# 🎯 SOLUÇÃO: BUILD ARGS NO EASYPANEL

## 📚 DESCOBERTA NA DOCUMENTAÇÃO

Segundo a [documentação oficial do Easypanel](https://easypanel.io/docs/services/app):

> **Environment**: This is where you will put the contents of your .env file. **These variables will be available at build-time and run-time.**

## ✅ SOLUÇÃO CORRETA

**No Easypanel, NÃO existe uma seção separada de "Build Arguments"!**

As variáveis de ambiente configuradas na seção **"Ambiente"** (Environment) são automaticamente disponibilizadas **tanto no build-time quanto no run-time**.

Isso significa que você estava no lugar certo! 🎉

---

## 🔧 COMO CONFIGURAR (CORRETO)

### 1. Vá em "Ambiente" (Environment Variables)
Você já estava lá! Era o lugar correto.

### 2. Adicione as variáveis VITE_*
```
VITE_APP_ENV=production
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_WS_URL=https://api.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
VITE_TINYMCE_API_KEY=no-api-key
```

### 3. MAS ATENÇÃO! Precisa modificar o Dockerfile

O Dockerfile precisa ter instruções `ARG` para receber essas variáveis durante o build.

---

## 🚨 PROBLEMA IDENTIFICADO

O Dockerfile do frontend provavelmente **NÃO tem as instruções ARG** necessárias para receber as variáveis VITE_* durante o build.

### Dockerfile atual (provavelmente):
```dockerfile
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build  # ❌ Aqui o Vite não vê as variáveis VITE_*
```

### Dockerfile correto (precisa ser):
```dockerfile
FROM node:18 AS builder

# ✅ Declarar ARGs para receber as variáveis do Easypanel
ARG VITE_APP_ENV
ARG VITE_API_URL
ARG VITE_AUTH_API_URL
ARG VITE_WS_URL
ARG VITE_EVOAI_API_URL
ARG VITE_AGENT_PROCESSOR_URL
ARG VITE_TINYMCE_API_KEY

# ✅ Converter ARGs em ENVs para o Vite usar
ENV VITE_APP_ENV=$VITE_APP_ENV
ENV VITE_API_URL=$VITE_API_URL
ENV VITE_AUTH_API_URL=$VITE_AUTH_API_URL
ENV VITE_WS_URL=$VITE_WS_URL
ENV VITE_EVOAI_API_URL=$VITE_EVOAI_API_URL
ENV VITE_AGENT_PROCESSOR_URL=$VITE_AGENT_PROCESSOR_URL
ENV VITE_TINYMCE_API_KEY=$VITE_TINYMCE_API_KEY

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build  # ✅ Agora o Vite vê as variáveis!

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## 📝 AÇÃO NECESSÁRIA

### Opção 1: Modificar o Dockerfile no repositório (RECOMENDADO)

1. Editar o Dockerfile do frontend no repositório Git
2. Adicionar as instruções `ARG` e `ENV` conforme exemplo acima
3. Commit e push
4. No Easypanel, adicionar as variáveis em "Ambiente"
5. Rebuild

### Opção 2: Usar a aba "Dockerfile" no Easypanel

1. No Easypanel, vá em "Fonte" → Aba "Dockerfile"
2. Cole o Dockerfile completo com as instruções ARG/ENV
3. Vá em "Ambiente" e adicione as variáveis VITE_*
4. Salvar e Rebuild

---

## 🎯 FLUXO CORRETO NO EASYPANEL

```
1. Easypanel lê as variáveis de "Ambiente"
   ↓
2. Durante o build, passa essas variáveis como --build-arg
   ↓
3. Dockerfile recebe via ARG
   ↓
4. Dockerfile converte ARG → ENV
   ↓
5. Vite lê as ENV durante npm run build
   ↓
6. Variáveis são injetadas no JavaScript
   ↓
7. Build completo com URLs corretas! ✅
```

---

## 🔍 VERIFICAR O DOCKERFILE ATUAL

Precisamos ver o Dockerfile atual do frontend para confirmar se ele tem as instruções ARG.

**Caminho provável**: `evo-ai-crm-community-main/Dockerfile` ou `evo-ai-crm-community-main/docker/Dockerfile`

---

## 📊 RESUMO

| Item | Status |
|------|--------|
| Seção "Ambiente" no Easypanel | ✅ Lugar correto |
| Variáveis VITE_* configuradas | ✅ Corretas |
| Dockerfile com ARG/ENV | ❓ Precisa verificar |

**Próximo passo**: Verificar e corrigir o Dockerfile do frontend.
