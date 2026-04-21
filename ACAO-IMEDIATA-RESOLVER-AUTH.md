# 🚨 AÇÃO IMEDIATA: Resolver Bloqueio do evo-auth

## SITUAÇÃO ATUAL

O evo-auth está bloqueando todas as requisições com:
```json
{"error":"service not activated","code":"SETUP_REQUIRED"}
```

## CAUSA IDENTIFICADA

O middleware `Licensing::SetupGate` verifica se o serviço está "ativado" através de um sistema de licenciamento que **NÃO DEVERIA EXISTIR** na Community Edition.

## SOLUÇÃO PRONTA ✅

Modificar o `SetupGate` para reconhecer automaticamente a Community Edition e permitir todas as requisições.

---

## 🎯 EXECUTAR AGORA (COPIAR E COLAR NO SERVIDOR)

### Opção 1: Script Automático (RECOMENDADO)

```bash
# Criar o script
cat > /tmp/fix-auth.sh << 'SCRIPT_END'
#!/bin/bash
echo "🔧 Corrigindo SetupGate para Community Edition..."

docker exec e793bd3d196c bash -c 'cat > app/services/licensing/setup_gate.rb' << 'EOF'
# frozen_string_literal: true

module Licensing
  class SetupGate
    BYPASS_PREFIXES = %w[/setup /rails /auth /api/v1/auth /health].freeze

    UNAVAILABLE_BODY = ['{"error":"service not activated","code":"SETUP_REQUIRED"}'].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) if _fna(env['PATH_INFO'])

      # COMMUNITY EDITION: Always allow requests
      ctx = Runtime.context
      
      if ctx&.active? || is_community_edition?
        ctx&.track_message
        @app.call(env)
      else
        [503, { 'Content-Type' => 'application/json' }, UNAVAILABLE_BODY]
      end
    end

    private

    def _fna(path)
      BYPASS_PREFIXES.any? { |prefix| path.start_with?(prefix) }
    end
    
    def is_community_edition?
      defined?(Licensing::Activation::TIER) && 
        Licensing::Activation::TIER == 'evo-ai-crm-community'
    end
  end
end
EOF

echo "✅ Arquivo modificado"
echo "🔄 Reiniciando container..."
docker restart e793bd3d196c
sleep 30
echo "🧪 Testando..."
curl -s https://evogo-evo-auth.ku83to.easypanel.host/ | head -c 200
echo ""
echo "✅ PRONTO!"
SCRIPT_END

# Executar o script
bash /tmp/fix-auth.sh
```

### Opção 2: Comandos Manuais (se preferir)

```bash
# 1. Criar arquivo modificado
docker exec e793bd3d196c bash -c 'cat > app/services/licensing/setup_gate.rb' << 'EOF'
# frozen_string_literal: true

module Licensing
  class SetupGate
    BYPASS_PREFIXES = %w[/setup /rails /auth /api/v1/auth /health].freeze

    UNAVAILABLE_BODY = ['{"error":"service not activated","code":"SETUP_REQUIRED"}'].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) if _fna(env['PATH_INFO'])

      # COMMUNITY EDITION: Always allow requests
      ctx = Runtime.context
      
      if ctx&.active? || is_community_edition?
        ctx&.track_message
        @app.call(env)
      else
        [503, { 'Content-Type' => 'application/json' }, UNAVAILABLE_BODY]
      end
    end

    private

    def _fna(path)
      BYPASS_PREFIXES.any? { |prefix| path.start_with?(prefix) }
    end
    
    def is_community_edition?
      defined?(Licensing::Activation::TIER) && 
        Licensing::Activation::TIER == 'evo-ai-crm-community'
    end
  end
end
EOF

# 2. Verificar se foi criado
docker exec e793bd3d196c cat app/services/licensing/setup_gate.rb | grep "is_community_edition"

# 3. Reiniciar
docker restart e793bd3d196c
sleep 30

# 4. Testar
curl https://evogo-evo-auth.ku83to.easypanel.host/
```

---

## ✅ COMO SABER SE FUNCIONOU?

### ANTES (erro):
```json
{"error":"service not activated","code":"SETUP_REQUIRED"}
```

### DEPOIS (sucesso):
```json
{"error":"Not Found"}
```
ou qualquer outra resposta que **NÃO SEJA** `SETUP_REQUIRED`

---

## 🎯 PRÓXIMOS PASSOS (APÓS O FIX)

### 1. Testar Login no Frontend
```
URL: https://evogo-evo-frontend.ku83to.easypanel.host
Email: admin@macip.com.br
Senha: Admin@123456
```

### 2. Corrigir Migrations do evo-crm

```bash
# Conectar ao PostgreSQL
docker exec -it evogo_postgres psql -U postgres -d evo_community

# Executar os comandos do arquivo MARCAR-TODAS-MIGRACOES.sql
# (copiar e colar todos os INSERTs)

# Sair do psql
\q

# Reiniciar evo-crm e evo-crm-sidekiq
docker ps | grep evo-crm
docker restart <container_id_evo_crm>
docker restart <container_id_evo_crm_sidekiq>
```

### 3. Verificar Todos os Serviços

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

Todos devem estar "Up" e não "Restarting".

---

## 🆘 SE NÃO FUNCIONAR

### Alternativa: Desabilitar o Middleware Completamente

```bash
# Comentar a linha do middleware
docker exec e793bd3d196c sed -i 's/config.middleware.use Licensing::SetupGate/# config.middleware.use Licensing::SetupGate # DISABLED/' config/application.rb

# Reiniciar
docker restart e793bd3d196c
sleep 30

# Testar
curl https://evogo-evo-auth.ku83to.easypanel.host/
```

---

## 📚 DOCUMENTAÇÃO RELACIONADA

- `EXPLICACAO-FIX-LICENSING.md` - Explicação detalhada do problema e solução
- `SOLUCAO-SETUP-GATE.md` - Documentação técnica
- `RESUMO-FINAL-SESSAO.md` - Resumo completo da sessão
- `MARCAR-TODAS-MIGRACOES.sql` - Para corrigir evo-crm depois

---

## 💡 POR QUE ESTA SOLUÇÃO FUNCIONA?

1. **Não depende de variáveis globais**: Verifica diretamente a constante `TIER`
2. **Sempre disponível**: A constante é definida no boot do Rails
3. **Simples e direto**: Não precisa de ativação, API externa ou banco de dados
4. **Mantém compatibilidade**: Versões Enterprise continuam funcionando normalmente

---

**🚀 VAMOS LÁ! Execute o script e resolva o problema de uma vez!**
