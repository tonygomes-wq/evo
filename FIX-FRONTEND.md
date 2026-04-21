# 🔧 Correção do Frontend

## 🔍 DIAGNÓSTICO

Os logs mostram que o Nginx está funcionando e servindo os arquivos estáticos corretamente:
- ✅ Nginx iniciado
- ✅ Arquivos CSS e JS carregados
- ✅ Favicon carregado

**Problema:** O frontend não consegue se comunicar com o backend.

---

## ✅ SOLUÇÃO 1: Verificar Variáveis de Ambiente do Frontend

### No Easypanel → evo-frontend → Ambiente

Verificar se estas variáveis estão corretas:

```env
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_WS_URL=https://api.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
```

**IMPORTANTE:** Essas variáveis precisam ser definidas como **Build Args** também!

---

## ✅ SOLUÇÃO 2: Configurar Build Args

### No Easypanel → evo-frontend → Fonte (Source)

Na seção **"Build Arguments"** ou **"Args de Build"**, adicionar:

```
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
```

**Depois fazer REBUILD do frontend!**

---

## ✅ SOLUÇÃO 3: Verificar CORS no Backend

### Verificar variável CORS_ORIGINS no evo-crm

**No Easypanel → evo-crm → Ambiente:**

```env
CORS_ORIGINS=https://evo.macip.com.br,https://api.macip.com.br
```

**Deve incluir o domínio do frontend:** `https://evo.macip.com.br`

Se não estiver, adicionar e reiniciar o evo-crm.

---

## ✅ SOLUÇÃO 4: Testar Conectividade

### 1. Testar se o backend está acessível

```bash
curl https://api.macip.com.br/health/live
```

**Deve retornar:**
```json
{"status":"ok"}
```

### 2. Testar se o auth está acessível

```bash
curl https://auth.macip.com.br/health
```

**Deve retornar algo como:**
```json
{"status":"ok"}
```

### 3. Abrir Console do Navegador

1. Abrir `https://evo.macip.com.br`
2. Pressionar F12 (abrir DevTools)
3. Ir na aba **Console**
4. Verificar se há erros de:
   - CORS
   - Network
   - 404 (Not Found)
   - 500 (Server Error)

---

## 🎯 PASSO A PASSO RECOMENDADO

### 1. Verificar Build Args (MAIS PROVÁVEL)

**No Easypanel:**
```
1. evo-frontend → Fonte (Source)
2. Procurar seção "Build Arguments" ou "Args"
3. Adicionar as variáveis VITE_*
4. Salvar
5. Rebuild
6. Aguardar 2-3 minutos
```

### 2. Verificar Variáveis de Ambiente

**No Easypanel:**
```
1. evo-frontend → Ambiente
2. Verificar se tem todas as variáveis VITE_*
3. Se não tiver, adicionar
4. Salvar
5. Reiniciar
```

### 3. Verificar CORS no Backend

**No Easypanel:**
```
1. evo-crm → Ambiente
2. Verificar CORS_ORIGINS
3. Deve incluir: https://evo.macip.com.br
4. Se não tiver, adicionar
5. Salvar
6. Reiniciar
```

---

## 📋 CHECKLIST

### Build Args do Frontend
- [ ] VITE_API_URL configurado
- [ ] VITE_AUTH_API_URL configurado
- [ ] VITE_EVOAI_API_URL configurado
- [ ] VITE_AGENT_PROCESSOR_URL configurado
- [ ] Rebuild executado

### Variáveis de Ambiente do Frontend
- [ ] VITE_API_URL=https://api.macip.com.br
- [ ] VITE_AUTH_API_URL=https://auth.macip.com.br
- [ ] VITE_WS_URL=https://api.macip.com.br
- [ ] VITE_EVOAI_API_URL=https://core.macip.com.br
- [ ] VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br

### CORS no Backend
- [ ] CORS_ORIGINS inclui https://evo.macip.com.br
- [ ] evo-crm reiniciado

### Testes
- [ ] Backend acessível (curl)
- [ ] Auth acessível (curl)
- [ ] Frontend carrega
- [ ] Console do navegador sem erros
- [ ] Login funcionando

---

## 🔍 ERROS COMUNS NO CONSOLE DO NAVEGADOR

### Erro: "CORS policy"
```
Access to fetch at 'https://api.macip.com.br' from origin 'https://evo.macip.com.br' 
has been blocked by CORS policy
```

**Solução:** Adicionar `https://evo.macip.com.br` no CORS_ORIGINS do evo-crm

### Erro: "Failed to fetch"
```
Failed to fetch
TypeError: Failed to fetch
```

**Solução:** Verificar se as URLs da API estão corretas nas variáveis VITE_*

### Erro: "404 Not Found"
```
GET https://api.macip.com.br/api/v1/... 404 (Not Found)
```

**Solução:** Verificar se o backend está rodando e acessível

---

## 📝 VALORES CORRETOS

### Build Args (Frontend)
```
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
```

### Variáveis de Ambiente (Frontend)
```env
VITE_APP_ENV=production
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_WS_URL=https://api.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
```

### CORS (Backend - evo-crm)
```env
CORS_ORIGINS=https://evo.macip.com.br,https://api.macip.com.br
FRONTEND_URL=https://evo.macip.com.br
BACKEND_URL=https://api.macip.com.br
```

---

## ⏱️ TEMPO ESTIMADO

- Verificar configurações: 2 min
- Adicionar Build Args: 1 min
- Rebuild frontend: 3 min
- Verificar CORS: 1 min
- Reiniciar backend: 1 min
- Testar: 1 min
- **Total: 9 minutos**

---

## 🎯 AÇÃO RECOMENDADA

**1. Adicionar Build Args no frontend (MAIS IMPORTANTE)**
**2. Rebuild do frontend**
**3. Verificar CORS no backend**

---

**Última atualização:** 21/04/2026  
**Prioridade:** ALTA
