# 🚀 AÇÃO IMEDIATA: CORRIGIR FRONTEND

## ⚡ RESUMO EXECUTIVO

**Problema**: Frontend não se comunica com backends  
**Causa**: Variáveis VITE_* não foram injetadas no build  
**Solução**: Adicionar como Build Args e rebuild  
**Tempo**: 5-10 minutos  

---

## 📋 CHECKLIST RÁPIDO

### No Easypanel:

1. **Abrir serviço**
   - [ ] Projeto: evogo
   - [ ] Serviço: evo-frontend
   - [ ] Aba: **Build** (não Environment)

2. **Adicionar Build Args** (copie e cole):
   ```
   VITE_APP_ENV=production
   VITE_API_URL=https://api.macip.com.br
   VITE_AUTH_API_URL=https://auth.macip.com.br
   VITE_WS_URL=https://api.macip.com.br
   VITE_EVOAI_API_URL=https://core.macip.com.br
   VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
   VITE_TINYMCE_API_KEY=no-api-key
   ```

3. **Rebuild**
   - [ ] Clicar em "Save"
   - [ ] Clicar em "Rebuild" (NÃO restart)
   - [ ] Aguardar 2-5 minutos

4. **Testar**
   - [ ] Acessar: https://evogo-evo-frontend.ku83to.easypanel.host/
   - [ ] Verificar se carrega
   - [ ] Abrir Console (F12)
   - [ ] Verificar se não há erros

---

## ✅ COMO SABER SE FUNCIONOU

No Console do navegador (F12), digite:
```javascript
console.log(import.meta.env)
```

Deve mostrar:
```javascript
{
  VITE_APP_ENV: "production",
  VITE_API_URL: "https://api.macip.com.br",
  VITE_AUTH_API_URL: "https://auth.macip.com.br",
  // ... outras variáveis
}
```

Se aparecer isso → **FUNCIONOU!** ✅

---

## 🆘 SE NÃO FUNCIONAR

1. Confirme que adicionou em **Build Args** (não Environment)
2. Confirme que fez **Rebuild** (não Restart)
3. Aguarde o build completar (veja os logs)
4. Limpe o cache do navegador (Ctrl+Shift+R)

---

## 📚 DOCUMENTAÇÃO COMPLETA

- `CORRIGIR-FRONTEND-AGORA.md` - Guia detalhado
- `ONDE-ADICIONAR-BUILD-ARGS.md` - Guia visual
- `ANALISE-COMPLETA-VARIAVEIS.md` - Análise completa

---

## 🎯 PRÓXIMO PASSO

Após o frontend funcionar, resolver as migrações do CRM:
- Arquivo: `SOLUCAO-DEFINITIVA.md`
- Script: `MARCAR-TODAS-MIGRACOES.sql`

**Mas primeiro, vamos resolver o frontend!** 🚀
