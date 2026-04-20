# ✅ Alterações de Domínio Realizadas

**Data:** 2025-04-20  
**Domínio Configurado:** macip.com.br

---

## 📋 Resumo das Alterações

Todos os arquivos de configuração e documentação foram atualizados para usar o domínio **macip.com.br** ao invés de "seudominio.com".

---

## 📝 Arquivos Atualizados

### 1. Configuração de Produção
- ✅ **`.env.production`** - Arquivo principal de configuração
  - Domínios atualizados para macip.com.br
  - URLs públicas configuradas
  - SMTP domain configurado
  - Frontend Build Args atualizados
  - Processor URLs atualizadas

### 2. Documentação de Secrets
- ✅ **`COMO-USAR-SECRETS.md`**
  - Exemplos de SMTP atualizados (Gmail, SendGrid, Mailgun)
  - URLs do Frontend atualizadas
  - Build Args do Frontend atualizados

### 3. Guias de Deploy
- ✅ **`GUIA-VISUAL-EASYPANEL.md`**
  - Tabela de domínios atualizada
  - Exemplos de configuração atualizados
  - Comandos de teste atualizados

- ✅ **`CONFIGURACAO-GITHUB-EASYPANEL.md`**
  - Todos os domínios de exemplo atualizados
  - URLs de configuração atualizadas
  - Build Args do Frontend atualizados

### 4. Checklist de Deploy
- ✅ **`CHECKLIST-DEPLOY-EASYPANEL.md`**
  - Lista de domínios atualizada
  - Endpoints de health check atualizados
  - URLs de teste atualizadas

---

## 🌐 Domínios Configurados

| Serviço | Domínio | Porta |
|---------|---------|-------|
| Frontend | `evo.macip.com.br` | 80 |
| Auth Service | `auth.macip.com.br` | 3001 |
| CRM Service | `api.macip.com.br` | 3000 |
| Core Service | `core.macip.com.br` | 5555 |
| Processor Service | `processor.macip.com.br` | 8000 |
| Bot Runtime | `bot.macip.com.br` | 8080 |

---

## 🔧 URLs Configuradas

### URLs Públicas (HTTPS)
```
FRONTEND_URL=https://evo.macip.com.br
BACKEND_URL=https://api.macip.com.br
```

### CORS Origins
```
CORS_ORIGINS=https://evo.macip.com.br,https://api.macip.com.br
```

### Frontend Build Args
```
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
```

### SMTP
```
SMTP_DOMAIN=macip.com.br
MAILER_SENDER_EMAIL=noreply@macip.com.br
```

---

## ⚠️ Próximos Passos

### 1. Configurar DNS
Você precisa criar os seguintes registros DNS apontando para o EasyPanel:

```
evo.macip.com.br          → IP do EasyPanel
auth.macip.com.br         → IP do EasyPanel
api.macip.com.br          → IP do EasyPanel
core.macip.com.br         → IP do EasyPanel
processor.macip.com.br    → IP do EasyPanel
bot.macip.com.br          → IP do EasyPanel (opcional)
```

**Tipo de registro:** A (IPv4) ou CNAME (se o EasyPanel fornecer um hostname)

### 2. Configurar SMTP
Editar o arquivo `.env.production` e configurar:
- `SMTP_USERNAME` - Seu email real
- `SMTP_PASSWORD` - Senha de app do provedor

### 3. Habilitar HTTPS/TLS
No EasyPanel, para cada serviço:
- Ir em Settings → Domain
- Habilitar "Enable TLS"
- Aguardar certificado ser gerado (Let's Encrypt)

### 4. Seguir Guia de Deploy
- Abrir: `GUIA-VISUAL-EASYPANEL.md` ou `CONFIGURACAO-GITHUB-EASYPANEL.md`
- Usar: `CHECKLIST-DEPLOY-EASYPANEL.md` durante o processo

---

## ✅ Verificação

Após o deploy, testar os endpoints:

```bash
# Health checks
curl https://auth.macip.com.br/health
curl https://api.macip.com.br/health/live
curl https://core.macip.com.br/health
curl https://processor.macip.com.br/health
curl https://bot.macip.com.br/health

# Frontend
curl https://evo.macip.com.br
```

Todos devem retornar 200 OK.

---

## 📞 Suporte

Se precisar reverter ou fazer ajustes:
1. Editar `.env.production`
2. Atualizar documentação conforme necessário
3. Fazer rebuild dos serviços no EasyPanel

---

**Status:** ✅ Domínios configurados e prontos para deploy  
**Próximo passo:** Configurar DNS e seguir guia de deploy

