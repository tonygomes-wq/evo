# 🚀 CORRIGIR FRONTEND - PASSO A PASSO

## 🎯 PROBLEMA IDENTIFICADO

O frontend está rodando, mas **não consegue se comunicar com os backends** porque as variáveis `VITE_*` não foram injetadas durante o build.

**Causa**: No Easypanel, variáveis VITE precisam ser **Build Args**, não Environment Variables.

---

## ✅ SOLUÇÃO PASSO A PASSO

### 1️⃣ Acessar configuração do serviço
```
1. Abra o Easypanel
2. Vá no projeto "evogo"
3. Clique no serviço "evo-frontend"
```

### 2️⃣ Configurar Build Args
```
1. Clique na aba "Build" (não "Environment")
2. Procure a seção "Build Arguments" ou "Build Args"
3. Adicione as seguintes variáveis:
```

**Copie e cole estas variáveis como Build Args:**

```
VITE_APP_ENV=production
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_WS_URL=https://api.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
VITE_TINYMCE_API_KEY=no-api-key
```

### 3️⃣ Salvar e Rebuild
```
1. Clique em "Save" ou "Salvar"
2. Clique em "Rebuild" (NÃO apenas "Restart")
3. Aguarde o build completar (pode levar 2-5 minutos)
```

### 4️⃣ Verificar se funcionou
```
1. Acesse: https://evogo-evo-frontend.ku83to.easypanel.host/
2. Abra o Console do navegador (F12)
3. Verifique se não há erros de conexão
4. Tente fazer login
```

---

## 🔍 COMO VERIFICAR SE AS BUILD ARGS FORAM APLICADAS

Após o rebuild, você pode verificar se as variáveis foram injetadas:

1. Acesse o frontend no navegador
2. Abra o Console (F12)
3. Digite: `console.log(import.meta.env)`
4. Você deve ver as variáveis VITE_* com os valores corretos

---

## 📋 CHECKLIST

- [ ] Acessei o Easypanel
- [ ] Abri o serviço evo-frontend
- [ ] Fui na aba "Build"
- [ ] Adicionei as 7 variáveis VITE_* como Build Args
- [ ] Salvei as configurações
- [ ] Cliquei em "Rebuild" (não restart)
- [ ] Aguardei o build completar
- [ ] Testei o acesso ao frontend
- [ ] Verifiquei o console do navegador

---

## ⚠️ IMPORTANTE

### Diferença entre Environment Variables e Build Args:

| Tipo | Quando é usado | Para que serve |
|------|----------------|----------------|
| **Environment Variables** | Runtime (quando o container roda) | Configurações do servidor (nginx, node, etc) |
| **Build Args** | Build time (quando o código é compilado) | Variáveis injetadas no código JavaScript |

### Para o Vite (frontend):
- ❌ Environment Variables → Não funcionam (são ignoradas)
- ✅ Build Args → Funcionam (são injetadas no JS)

---

## 🎯 RESULTADO ESPERADO

Após seguir estes passos:

1. ✅ Frontend carrega corretamente
2. ✅ Consegue se comunicar com os backends
3. ✅ Página de login funciona
4. ✅ Não há erros no console do navegador

---

## 🆘 SE AINDA NÃO FUNCIONAR

Verifique:

1. **Build completou com sucesso?**
   - Veja os logs do build no Easypanel
   - Procure por erros

2. **Build Args foram salvos?**
   - Volte na aba "Build"
   - Confirme que as 7 variáveis estão lá

3. **Fez Rebuild ou apenas Restart?**
   - Restart NÃO aplica Build Args
   - Precisa fazer Rebuild

4. **URLs dos backends estão corretas?**
   - https://api.macip.com.br → evo-crm
   - https://auth.macip.com.br → evo-auth
   - https://core.macip.com.br → evo-core
   - https://processor.macip.com.br → evo-processor

---

## 📞 PRÓXIMO PASSO APÓS FRONTEND FUNCIONAR

Depois que o frontend estiver funcionando, precisamos resolver o problema das migrações do CRM:

1. Executar o script `MARCAR-TODAS-MIGRACOES.sql` no PostgreSQL
2. Restart dos serviços evo-crm e evo-crm-sidekiq

Mas primeiro, vamos resolver o frontend! 🚀
