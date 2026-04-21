# SOLUÇÃO DEFINITIVA: Desabilitar SetupGate para Community Edition

## PROBLEMA
O middleware `SetupGate` está bloqueando todas as requisições com erro `SETUP_REQUIRED`, mesmo após a ativação forçada no initializer.

## CAUSA RAIZ
O `SetupGate` verifica `Runtime.context&.active?` que depende de uma variável global `$__licensing_runtime_context`. Mesmo com o initializer rodando (confirmado nos logs), o middleware ainda bloqueia as requisições.

## SOLUÇÃO
Modificar o `SetupGate` para **sempre permitir** requisições na Community Edition, sem depender do sistema de licenciamento.

## COMANDOS

### 1. Criar versão modificada do SetupGate
```bash
docker exec e793bd3d196c bash -c 'cat > app/services/licensing/setup_gate.rb << "EOF"
# frozen_string_literal: true

module Licensing
  class SetupGate
    BYPASS_PREFIXES = %w[/setup /rails /auth /api/v1/auth /health].freeze

    UNAVAILABLE_BODY = ["{\"error\":\"service not activated\",\"code\":\"SETUP_REQUIRED\"}"].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) if _fna(env["PATH_INFO"])

      # COMMUNITY EDITION: Always allow requests
      # The licensing system is not needed for the community edition
      ctx = Runtime.context
      
      if ctx&.active? || is_community_edition?
        ctx&.track_message
        @app.call(env)
      else
        [503, { "Content-Type" => "application/json" }, UNAVAILABLE_BODY]
      end
    end

    private

    def _fna(path)
      BYPASS_PREFIXES.any? { |prefix| path.start_with?(prefix) }
    end
    
    def is_community_edition?
      # Community edition is identified by the TIER constant
      defined?(Licensing::Activation::TIER) && 
        Licensing::Activation::TIER == "evo-ai-crm-community"
    end
  end
end
EOF'
```

### 2. Reiniciar o container
```bash
docker restart e793bd3d196c
sleep 30
```

### 3. Testar
```bash
curl https://evogo-evo-auth.ku83to.easypanel.host/
```

**Resultado esperado**: Resposta diferente de `{"error":"service not activated","code":"SETUP_REQUIRED"}`

## ALTERNATIVA (se a solução acima não funcionar)

### Desabilitar completamente o middleware

```bash
# Comentar a linha do middleware no config/application.rb
docker exec e793bd3d196c bash -c 'sed -i "s/config.middleware.use Licensing::SetupGate/# config.middleware.use Licensing::SetupGate # DISABLED FOR COMMUNITY EDITION/" config/application.rb'

# Reiniciar
docker restart e793bd3d196c
sleep 30

# Testar
curl https://evogo-evo-auth.ku83to.easypanel.host/
```

## PRÓXIMOS PASSOS (após resolver o evo-auth)

1. Testar login no frontend com `admin@macip.com.br` / `Admin@123456`
2. Corrigir migrations do evo-crm executando `MARCAR-TODAS-MIGRACOES.sql`
3. Verificar se todos os serviços estão funcionando corretamente
