# 📍 ONDE ADICIONAR BUILD ARGS NO EASYPANEL

## 🎯 LOCALIZAÇÃO EXATA

### Passo 1: Navegação
```
Easypanel Dashboard
  └── Projeto: evogo
      └── Serviço: evo-frontend
          └── Aba: "Build" (não "Environment")
              └── Seção: "Build Arguments" ou "Args"
```

---

## 🖼️ INTERFACE DO EASYPANEL

### Você verá algo assim:

```
┌─────────────────────────────────────────────────┐
│ evo-frontend                                    │
├─────────────────────────────────────────────────┤
│ [General] [Build] [Environment] [Domains] ...   │ ← Clique em "Build"
├─────────────────────────────────────────────────┤
│                                                 │
│ Build Configuration                             │
│                                                 │
│ ┌─────────────────────────────────────────┐   │
│ │ Build Path: evo-ai-crm-community-main   │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ ┌─────────────────────────────────────────┐   │
│ │ Dockerfile: Dockerfile                  │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ Build Arguments                                 │ ← AQUI!
│ ┌─────────────────────────────────────────┐   │
│ │ [+ Add Argument]                        │   │ ← Clique aqui
│ └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## ✍️ COMO ADICIONAR CADA VARIÁVEL

### Formato no Easypanel:

Cada Build Arg tem dois campos:

```
┌──────────────────────────────────────────┐
│ Key:   [VITE_APP_ENV            ]       │
│ Value: [production              ]       │
│                                  [Remove]│
└──────────────────────────────────────────┘
```

### Adicione uma por uma:

#### 1. VITE_APP_ENV
```
Key:   VITE_APP_ENV
Value: production
```

#### 2. VITE_API_URL
```
Key:   VITE_API_URL
Value: https://api.macip.com.br
```

#### 3. VITE_AUTH_API_URL
```
Key:   VITE_AUTH_API_URL
Value: https://auth.macip.com.br
```

#### 4. VITE_WS_URL
```
Key:   VITE_WS_URL
Value: https://api.macip.com.br
```

#### 5. VITE_EVOAI_API_URL
```
Key:   VITE_EVOAI_API_URL
Value: https://core.macip.com.br
```

#### 6. VITE_AGENT_PROCESSOR_URL
```
Key:   VITE_AGENT_PROCESSOR_URL
Value: https://processor.macip.com.br
```

#### 7. VITE_TINYMCE_API_KEY
```
Key:   VITE_TINYMCE_API_KEY
Value: no-api-key
```

---

## 🔄 APÓS ADICIONAR TODAS

### Você verá algo assim:

```
Build Arguments
┌──────────────────────────────────────────────────┐
│ VITE_APP_ENV = production                [Remove]│
│ VITE_API_URL = https://api.macip.com.br  [Remove]│
│ VITE_AUTH_API_URL = https://auth.mac...  [Remove]│
│ VITE_WS_URL = https://api.macip.com.br   [Remove]│
│ VITE_EVOAI_API_URL = https://core.ma...  [Remove]│
│ VITE_AGENT_PROCESSOR_URL = https://p...  [Remove]│
│ VITE_TINYMCE_API_KEY = no-api-key        [Remove]│
└──────────────────────────────────────────────────┘

[Save]  [Cancel]
```

### Clique em "Save" e depois em "Rebuild"

---

## ⚠️ NÃO CONFUNDA

### ❌ ERRADO: Adicionar em "Environment"
```
[General] [Build] [Environment] ← NÃO AQUI!
```

### ✅ CORRETO: Adicionar em "Build"
```
[General] [Build] ← AQUI! [Environment]
          ↑
       AQUI!
```

---

## 🎯 DIFERENÇA VISUAL

### Environment Variables (Runtime)
```
Usado para: Configurações do servidor
Exemplo: PORT=3000, NODE_ENV=production
Quando: Container está rodando
```

### Build Arguments (Build Time)
```
Usado para: Variáveis injetadas no código
Exemplo: VITE_API_URL=https://...
Quando: Durante o build do código
```

---

## 📝 CHECKLIST VISUAL

Ao adicionar Build Args, você deve ver:

- [ ] Estou na aba "Build" (não "Environment")
- [ ] Vejo a seção "Build Arguments" ou "Args"
- [ ] Consigo clicar em "+ Add Argument"
- [ ] Cada argumento tem dois campos: Key e Value
- [ ] Adicionei todas as 7 variáveis VITE_*
- [ ] Cliquei em "Save"
- [ ] Cliquei em "Rebuild" (não "Restart")

---

## 🚀 APÓS O REBUILD

O Easypanel vai:

1. ✅ Baixar o código do repositório
2. ✅ Executar o Dockerfile
3. ✅ Passar as Build Args para o comando `docker build`
4. ✅ O Vite vai injetar as variáveis no JavaScript
5. ✅ Gerar os arquivos estáticos com as URLs corretas
6. ✅ Nginx vai servir os arquivos

**Tempo estimado**: 2-5 minutos

---

## 🔍 COMO CONFIRMAR QUE FUNCIONOU

### No navegador:

1. Acesse o frontend
2. Abra o Console (F12)
3. Digite: `console.log(import.meta.env)`
4. Você deve ver:

```javascript
{
  VITE_APP_ENV: "production",
  VITE_API_URL: "https://api.macip.com.br",
  VITE_AUTH_API_URL: "https://auth.macip.com.br",
  VITE_WS_URL: "https://api.macip.com.br",
  VITE_EVOAI_API_URL: "https://core.macip.com.br",
  VITE_AGENT_PROCESSOR_URL: "https://processor.macip.com.br",
  VITE_TINYMCE_API_KEY: "no-api-key"
}
```

Se você ver isso, **FUNCIONOU!** ✅

---

## 🆘 SE NÃO ENCONTRAR "BUILD ARGUMENTS"

Algumas versões do Easypanel podem ter nomes diferentes:

- "Build Arguments"
- "Build Args"
- "ARG"
- "Docker Build Args"
- "Build-time Variables"

Procure por qualquer seção na aba "Build" que permita adicionar variáveis.

---

## 📞 RESUMO

1. ✅ Aba "Build" (não "Environment")
2. ✅ Seção "Build Arguments"
3. ✅ Adicionar 7 variáveis VITE_*
4. ✅ Save + Rebuild
5. ✅ Aguardar 2-5 minutos
6. ✅ Testar no navegador

**É isso! Simples e direto.** 🚀
