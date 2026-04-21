# 🔧 Correção: evo-crm-sidekiq - Erro de arquivo .env

## 🔴 ERRO IDENTIFICADO

```
ENOENT: no such file or directory, open '/etc/easypanel/projects/evogo/evo-crm-sidekiq/code/evo-ai-crm-community/.env'
```

O serviço está tentando ler um arquivo `.env` que não existe.

---

## ✅ SOLUÇÃO 1: Verificar Configuração no Easypanel (RÁPIDO)

### Passo 1: Verificar Caminho de Build

**No Easypanel → evo-crm-sidekiq → Aba "Fonte":**

```
✅ Repositório: evo-ai-crm-community-main
✅ Branch: main
✅ Caminho de Build: evo-ai-crm-community-main (SEM barra inicial)
✅ Dockerfile: docker/Dockerfile
```

### Passo 2: Verificar Comando

**No Easypanel → evo-crm-sidekiq → Aba "Geral":**

**Campo "Comando" ou "Start Command":**
```bash
bundle exec sidekiq -C config/sidekiq.yml
```

**IMPORTANTE:** 
- NÃO deve ter `dotenv` ou referência a `.env`
- Se tiver algo como `bundle exec dotenv sidekiq`, REMOVER o `dotenv`

### Passo 3: Salvar e Rebuild

1. Clicar em **"Salvar"**
2. Clicar em **"Rebuild"**
3. Aguardar build completar

---

## ✅ SOLUÇÃO 2: Modificar Dockerfile para Criar .env Vazio

Se a solução 1 não funcionar, o código pode estar forçando a leitura do `.env`.

### Criar Dockerfile Modificado

Vamos adicionar uma linha no Dockerfile para criar um `.env` vazio:

**Adicionar antes do CMD:**
```dockerfile
# Create empty .env file if it doesn't exist (for compatibility)
RUN touch /app/.env
```

---

## ✅ SOLUÇÃO 3: Desabilitar dotenv-rails em Produção

O problema pode ser a gem `dotenv-rails` tentando carregar o `.env` em produção.

### Verificar Gemfile

O `dotenv-rails` deve estar apenas no grupo development/test:

```ruby
group :development, :test do
  gem 'dotenv-rails'
end
```

**NÃO deve estar assim:**
```ruby
gem 'dotenv-rails'  # ❌ ERRADO - carrega em produção
```

---

## 🎯 AÇÃO IMEDIATA RECOMENDADA

### Opção A: Verificar Comando (Mais Provável)

1. **Acessar Easypanel:**
   - Projeto: `evogo`
   - Serviço: `evo-crm-sidekiq`

2. **Ir para aba "Geral"**

3. **Verificar campo "Comando" ou "Start Command":**
   - Se estiver vazio, adicionar: `bundle exec sidekiq -C config/sidekiq.yml`
   - Se tiver `dotenv`, remover: mudar de `bundle exec dotenv sidekiq` para `bundle exec sidekiq -C config/sidekiq.yml`

4. **Salvar e Rebuild**

---

### Opção B: Criar .env Vazio no Build

Se a Opção A não funcionar, adicione esta linha no Dockerfile:

**Localização:** Após a linha `WORKDIR /app` e antes do `CMD`

```dockerfile
# Create empty .env for compatibility
RUN touch /app/.env
```

---

## 📋 Checklist de Verificação

### Configuração do Easypanel
- [ ] Caminho de Build: `evo-ai-crm-community-main` (sem /)
- [ ] Dockerfile: `docker/Dockerfile`
- [ ] Comando: `bundle exec sidekiq -C config/sidekiq.yml`
- [ ] Sem referência a `dotenv` no comando

### Variáveis de Ambiente
- [ ] POSTGRES_PASSWORD: `355cbf3375d96724de1f`
- [ ] REDIS_URL: `redis://default:d9kizl4kz7riul5ah7if@evogo_redis:6379`
- [ ] RAILS_ENV: `production`
- [ ] Todas as outras variáveis configuradas

---

## 🔍 Diagnóstico Adicional

### Verificar se o problema é o comando

O erro aparece durante o **build** ou durante o **start**?

**Se aparecer durante BUILD:**
- O problema está no Dockerfile
- Solução: Adicionar `RUN touch /app/.env` no Dockerfile

**Se aparecer durante START:**
- O problema está no comando de inicialização
- Solução: Corrigir o comando para não usar `dotenv`

---

## 📝 Comando Correto para Sidekiq

### ✅ CORRETO
```bash
bundle exec sidekiq -C config/sidekiq.yml
```

### ❌ INCORRETO
```bash
bundle exec dotenv sidekiq
dotenv bundle exec sidekiq
bundle exec rails runner "require 'dotenv'; Dotenv.load; exec 'bundle exec sidekiq'"
```

---

## 🎯 Resumo da Solução

1. **Verificar comando no Easypanel** (campo "Comando" ou "Start Command")
2. **Garantir que é:** `bundle exec sidekiq -C config/sidekiq.yml`
3. **Remover qualquer referência a** `dotenv`
4. **Salvar e Rebuild**

---

## 📞 Se Ainda Não Funcionar

Envie:
1. Screenshot da aba "Geral" do evo-crm-sidekiq (campo Comando)
2. Screenshot da aba "Fonte" (configuração de build)
3. Log completo do erro

---

**Última atualização:** 21/04/2026  
**Prioridade:** ALTA
