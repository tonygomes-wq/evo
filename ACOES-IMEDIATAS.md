# ⚡ AÇÕES IMEDIATAS - Correção dos Serviços

## 🎯 O QUE FAZER AGORA (10 minutos)

---

## 🔴 PROBLEMA IDENTIFICADO

Três serviços não estão iniciando:
1. **evo-crm** - Senha PostgreSQL incorreta + Redis sem autenticação + Erro de migração
2. **evo-crm-sidekiq** - Caminho de build incorreto + Mesmos problemas de senha

---

## ✅ SOLUÇÃO RÁPIDA

### 🔧 AÇÃO 1: Corrigir evo-crm (3 minutos)

**No Easypanel → Projeto evogo → Serviço evo-crm → Aba "Ambiente":**

1. **Localizar e corrigir:**
   ```
   POSTGRES_PASSWORD
   DE: 355cbf3375d96724d0ff
   PARA: 355cbf3375d96724de1f
   ```

2. **Localizar e corrigir:**
   ```
   REDIS_URL
   DEVE SER: redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379
   ```

3. **Clicar em "Salvar" e depois "Reiniciar"**

4. **Aguardar 30 segundos e verificar logs**

5. **Se aparecer erro "sentiment_offensive already exists":**
   - Abrir Console/Terminal do evo-crm
   - Executar:
   ```bash
   bundle exec rails runner "ActiveRecord::Base.connection.execute(\"INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING\")"
   ```
   - Reiniciar novamente

---

### 🔧 AÇÃO 2: Corrigir evo-crm-sidekiq (3 minutos)

**No Easypanel → Projeto evogo → Serviço evo-crm-sidekiq:**

1. **Aba "Fonte" (Source):**
   ```
   Caminho de Build
   DE: /evo-ai-crm-community-main
   PARA: evo-ai-crm-community-main
   
   (REMOVER a barra inicial /)
   ```

2. **Aba "Ambiente":**
   ```
   POSTGRES_PASSWORD: 355cbf3375d96724de1f
   REDIS_URL: redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379
   ```

3. **Clicar em "Salvar" e depois "Rebuild"**

4. **Aguardar build completar (2-3 minutos)**

---

### ✅ AÇÃO 3: Verificar (2 minutos)

**Testar health checks:**
```bash
curl https://api.macip.com.br/health/live
```

**Deve retornar:**
```json
{"status":"ok"}
```

**Testar login:**
1. Acessar: https://evo.macip.com.br
2. Email: support@evo-auth-service-community.com
3. Senha: Password@123

---

## 📋 CHECKLIST RÁPIDO

Marque conforme executar:

### evo-crm
- [ ] POSTGRES_PASSWORD = `355cbf3375d96724de1f`
- [ ] REDIS_URL = `redis://:dpkjzl4kz7riuI5ah7rf@evogo_redis:6379/0`
- [ ] Salvo e reiniciado
- [ ] Logs OK (sem erros)
- [ ] Health check OK

### evo-crm-sidekiq
- [ ] Caminho de build = `evo-ai-crm-community-main` (sem /)
- [ ] POSTGRES_PASSWORD corrigido
- [ ] REDIS_URL corrigido
- [ ] Salvo e rebuild
- [ ] Build OK
- [ ] Serviço Running

### Verificação Final
- [ ] Todos os 8 serviços Running
- [ ] Health check retorna OK
- [ ] Login funcionando
- [ ] Dashboard carregando

---

## 🚨 SE ALGO DER ERRADO

### Erro: "password authentication failed"
→ Verificar se POSTGRES_PASSWORD está exatamente: `355cbf3375d96724de1f`

### Erro: "WRONGPASS" ou "NOAUTH"
→ Verificar se REDIS_URL está exatamente: `redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379`

### Erro: "sentiment_offensive already exists"
→ Executar comando no console do evo-crm (ver AÇÃO 1, passo 5)

### Erro: "no such file or directory" no build
→ Verificar se caminho de build está SEM barra inicial

---

## 📞 VALORES CORRETOS - COPIAR E COLAR

### PostgreSQL Password
```
355cbf3375d96724de1f
```

### Redis URL
```
redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379
```

### Build Path
```
evo-ai-crm-community-main
```

### Dockerfile Path
```
docker/Dockerfile
```

---

## ⏱️ TEMPO TOTAL: 10 MINUTOS

- Ação 1 (evo-crm): 3 min
- Ação 2 (evo-crm-sidekiq): 3 min  
- Ação 3 (verificação): 2 min
- Margem: 2 min

---

## 📚 DOCUMENTAÇÃO COMPLETA

Para mais detalhes, consultar:
- `FIX-SERVICOS-NAO-INICIANDO.md` - Explicação completa dos problemas
- `PASSO-A-PASSO-CORRECAO.md` - Guia detalhado passo a passo
- `COMANDOS-DIAGNOSTICO-BD.md` - Comandos SQL para diagnóstico

---

## ✅ APÓS CORREÇÃO

Quando todos os serviços estiverem funcionando:

1. ✅ Fazer backup do banco de dados
2. ✅ Documentar as configurações finais
3. ✅ Testar fluxo completo de conversação
4. ✅ Configurar monitoramento
5. ✅ Configurar alertas

---

**IMPORTANTE:** Execute as ações NA ORDEM apresentada!

**Última atualização:** 21/04/2026
