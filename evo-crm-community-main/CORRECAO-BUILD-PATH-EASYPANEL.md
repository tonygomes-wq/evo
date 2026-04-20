# 🔧 Correção: Build Path no EasyPanel

**Problema:** Build falhou com erro "Dockerfile not found"

**Causa:** O Build Path configurado está incorreto para a estrutura do repositório GitHub.

---

## 📋 Estrutura Real do Repositório GitHub

O repositório `https://github.com/tonygomes-wq/evo` tem esta estrutura:

```
tonygomes-wq/evo/
├── evo-auth-service-community-main/
│   ├── Dockerfile
│   ├── Gemfile
│   └── ...
├── evo-ai-core-service-community-main/
│   ├── Dockerfile
│   ├── go.mod
│   └── ...
├── evo-ai-processor-community-main/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── ...
├── evo-ai-frontend-community-main/
│   ├── Dockerfile
│   ├── package.json
│   └── ...
├── evo-bot-runtime-main/
│   ├── Dockerfile
│   ├── go.mod
│   └── ...
└── evo-crm-community-main/
    ├── evo-ai-crm-community/  ← VAZIO (submodule não clonado)
    ├── docker-compose.yml
    └── documentação...
```

---

## ⚠️ Problema: Submodules Não Clonados

O repositório usa **Git Submodules**, mas o EasyPanel não clona submodules automaticamente por padrão.

A pasta `evo-crm-community-main/evo-ai-crm-community/` está **vazia** porque é um submodule.

---

## ✅ Solução: Usar Pastas Standalone

Cada serviço tem sua própria pasta **standalone** na raiz do repositório.

### Configuração Correta no EasyPanel:

| Serviço | Build Path Correto | Dockerfile Path |
|---------|-------------------|-----------------|
| **Auth** | `/evo-auth-service-community-main` | `Dockerfile` |
| **CRM** | **❌ NÃO EXISTE STANDALONE** | - |
| **Core** | `/evo-ai-core-service-community-main` | `Dockerfile` |
| **Processor** | `/evo-ai-processor-community-main` | `Dockerfile` |
| **Bot Runtime** | `/evo-bot-runtime-main` | `Dockerfile` |
| **Frontend** | `/evo-ai-frontend-community-main` | `Dockerfile` |

---

## 🚨 Problema Crítico: CRM Service

O **CRM Service** NÃO tem pasta standalone na raiz do repositório!

Ele está dentro de `evo-crm-community-main/evo-ai-crm-community/`, mas essa pasta é um **submodule vazio**.

### Opções para Resolver:

#### Opção 1: Habilitar Submodules no EasyPanel (Recomendado)

No EasyPanel, ao configurar o serviço CRM:

1. Ir em **Settings** → **Source**
2. Procurar por opção **"Clone Submodules"** ou **"Recursive Clone"**
3. Habilitar essa opção
4. Fazer rebuild

**Build Path:**
```
/evo-crm-community-main/evo-ai-crm-community
```

**Dockerfile Path:**
```
docker/Dockerfile
```

#### Opção 2: Verificar se CRM está em outro lugar

Verificar no GitHub se existe uma pasta standalone do CRM que não foi documentada.

#### Opção 3: Clonar manualmente o submodule

Se o EasyPanel não suporta submodules, você precisará:

1. Clonar o repositório localmente
2. Inicializar submodules: `git submodule update --init --recursive`
3. Fazer push do conteúdo do submodule para uma branch
4. Usar essa branch no EasyPanel

---

## 🔧 Como Corrigir Agora

### Para o serviço CRM que falhou:

1. **No EasyPanel**, ir no serviço `evo-crm`
2. Ir em **Settings** → **Source**
3. Verificar se existe opção para **"Clone Submodules"** ou **"Recursive Clone"**
4. Se existir, **habilitar**
5. Ir em **Actions** → **Rebuild**

### Se não existir opção de submodules:

Você precisará verificar no GitHub se o código do CRM está em outro lugar ou se precisa ser clonado manualmente.

---

## 📝 Configuração Correta para Cada Serviço

### 1. Auth Service ✅

```yaml
Repository: tonygomes-wq/evo
Branch: main
Build Path: /evo-auth-service-community-main
Dockerfile Path: Dockerfile
Build Context: /evo-auth-service-community-main
```

### 2. CRM Service ⚠️

**Opção A (com submodules):**
```yaml
Repository: tonygomes-wq/evo
Branch: main
Build Path: /evo-crm-community-main/evo-ai-crm-community
Dockerfile Path: docker/Dockerfile
Build Context: /evo-crm-community-main/evo-ai-crm-community
Clone Submodules: YES ← IMPORTANTE!
```

**Opção B (se não tiver submodules):**
Verificar se existe pasta standalone do CRM na raiz.

### 3. Core Service ✅

```yaml
Repository: tonygomes-wq/evo
Branch: main
Build Path: /evo-ai-core-service-community-main
Dockerfile Path: Dockerfile
Build Context: /evo-ai-core-service-community-main
```

### 4. Processor Service ✅

```yaml
Repository: tonygomes-wq/evo
Branch: main
Build Path: /evo-ai-processor-community-main
Dockerfile Path: Dockerfile
Build Context: /evo-ai-processor-community-main
```

### 5. Bot Runtime ✅

```yaml
Repository: tonygomes-wq/evo
Branch: main
Build Path: /evo-bot-runtime-main
Dockerfile Path: Dockerfile
Build Context: /evo-bot-runtime-main
```

### 6. Frontend ✅

```yaml
Repository: tonygomes-wq/evo
Branch: main
Build Path: /evo-ai-frontend-community-main
Dockerfile Path: Dockerfile
Build Context: /evo-ai-frontend-community-main
```

---

## 🔍 Como Verificar no GitHub

1. Acessar: https://github.com/tonygomes-wq/evo
2. Verificar se existe pasta `evo-ai-crm-community-main` na raiz (standalone)
3. Se não existir, verificar se `evo-crm-community-main/evo-ai-crm-community/` tem conteúdo
4. Se estiver vazio, é submodule e precisa habilitar no EasyPanel

---

## 📞 Próximos Passos

1. **Verificar no GitHub** se CRM tem pasta standalone
2. **Habilitar submodules** no EasyPanel (se disponível)
3. **Fazer rebuild** do serviço CRM
4. Se não funcionar, **abrir issue** no GitHub para entender estrutura

---

## 🆘 Alternativa: Deploy Local Primeiro

Se o EasyPanel não suportar submodules, você pode:

1. Clonar localmente com submodules
2. Testar com `docker-compose` local
3. Depois fazer push para um repositório sem submodules
4. Usar esse repositório no EasyPanel

---

**Status:** ⚠️ Aguardando verificação de submodules no EasyPanel  
**Próximo passo:** Habilitar "Clone Submodules" e fazer rebuild

