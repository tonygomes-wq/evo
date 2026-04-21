# 🚨 CORREÇÃO URGENTE - Erro de Migração

## 🔴 PROBLEMA IDENTIFICADO

```
PG::DuplicateColumn: ERROR: column "sentiment_offensive" of relation "facebook_comment_moderations" already exists
```

A migração `20251114150000` está tentando criar uma coluna que já existe no banco de dados.

---

## ✅ SOLUÇÃO IMEDIATA (2 minutos)

### Opção 1: Via Console do Easypanel (RECOMENDADO)

#### Passo 1: Acessar Console do evo-crm

1. **No Easypanel:**
   - Projeto: `evogo`
   - Serviço: `evo-crm`
   - Clicar em **"Console"** ou **"Terminal"**
   - Selecionar **"Bash"**

#### Passo 2: Executar Comando

**Copie e cole este comando exatamente:**

```bash
bundle exec rails runner "ActiveRecord::Base.connection.execute(\"INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING\")"
```

**Pressione Enter e aguarde a mensagem de sucesso**

#### Passo 3: Reiniciar Serviços

1. **Fechar o console**
2. **Reiniciar evo-crm:**
   - Clicar em **"Reiniciar"** (Restart)
3. **Reiniciar evo-crm-sidekiq:**
   - Ir para serviço `evo-crm-sidekiq`
   - Clicar em **"Reiniciar"** (Restart)

---

### Opção 2: Via SQL Direto no PostgreSQL

Se não conseguir acessar o console do Rails:

#### Conectar ao PostgreSQL

```bash
PGPASSWORD=355cbf3375d96724de1f psql -h evogo_postgres -U postgres -d evo_community
```

#### Executar SQL

```sql
INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING;
```

#### Sair do psql

```sql
\q
```

#### Reiniciar Serviços

Reiniciar `evo-crm` e `evo-crm-sidekiq` no Easypanel

---

## 📋 PASSO A PASSO VISUAL

### 1. Acessar Console

```
Easypanel → evogo → evo-crm → Console → Bash
```

### 2. Copiar Comando

```bash
bundle exec rails runner "ActiveRecord::Base.connection.execute(\"INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING\")"
```

### 3. Colar no Console

- Clicar com botão direito no console
- Selecionar "Colar" ou usar Ctrl+V
- Pressionar Enter

### 4. Aguardar Confirmação

Deve aparecer algo como:
```
(sem erro = sucesso)
```

### 5. Reiniciar Serviços

- Fechar console
- evo-crm → Reiniciar
- evo-crm-sidekiq → Reiniciar

---

## ✅ VERIFICAÇÃO

### Logs do evo-crm

Após reiniciar, os logs devem mostrar:

```
✅ Puma starting in cluster mode
✅ Listening on http://0.0.0.0:3000
```

**NÃO deve mais aparecer:**
```
❌ PG::DuplicateColumn
❌ sentiment_offensive already exists
```

### Logs do evo-crm-sidekiq

Após reiniciar, os logs devem mostrar:

```
✅ Booting Sidekiq
✅ Running in ruby
✅ Starting processing
```

---

## 🎯 RESULTADO ESPERADO

Após executar o comando e reiniciar:

- ✅ evo-crm: Running (sem erro de migração)
- ✅ evo-crm-sidekiq: Running (sem erro de migração)
- ✅ Todos os 8 serviços funcionando
- ✅ Sistema operacional

---

## 🔍 O QUE O COMANDO FAZ

```sql
INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING
```

Este comando:
1. Insere o número da migração na tabela `schema_migrations`
2. Marca a migração como "já executada"
3. `ON CONFLICT DO NOTHING` evita erro se já existir
4. Rails não tentará executar a migração novamente

---

## 🚨 SE DER ERRO NO COMANDO

### Erro: "command not found: bundle"

Você está no console errado. Certifique-se de:
- Estar no console do **evo-crm** (não do Easypanel)
- Ter selecionado **"Bash"** (não "sh")

### Erro: "could not connect to database"

Verifique se o serviço evo-crm está rodando:
- Se não estiver, não é possível acessar o console
- Use a Opção 2 (SQL direto no PostgreSQL)

### Erro: "syntax error"

Certifique-se de copiar o comando EXATAMENTE como está:
- Incluindo todas as aspas e barras invertidas
- Não adicionar espaços extras
- Copiar tudo em uma linha

---

## ⏱️ TEMPO TOTAL

- Acessar console: 30 segundos
- Executar comando: 10 segundos
- Reiniciar serviços: 1 minuto
- **Total: 2 minutos**

---

## 📝 COMANDO COMPLETO (COPIAR DAQUI)

```bash
bundle exec rails runner "ActiveRecord::Base.connection.execute(\"INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING\")"
```

---

## 🎯 CHECKLIST

- [ ] Acessei console do evo-crm
- [ ] Copiei o comando exatamente
- [ ] Colei no console
- [ ] Pressionei Enter
- [ ] Aguardei conclusão (sem erro)
- [ ] Fechei console
- [ ] Reiniciei evo-crm
- [ ] Reiniciei evo-crm-sidekiq
- [ ] Verifiquei logs (sem erro de migração)
- [ ] Ambos serviços Running

---

## 📞 PRÓXIMO PASSO

Após executar esta correção:

1. ✅ Verificar se todos os 8 serviços estão Running
2. ✅ Testar health check: `curl https://api.macip.com.br/health/live`
3. ✅ Testar login no frontend
4. ✅ Criar conversa de teste

---

**Última atualização:** 21/04/2026  
**Prioridade:** CRÍTICA  
**Tempo:** 2 minutos  
**Dificuldade:** Fácil
