# ⚡ QUICK START: Fix evo-auth em 1 Minuto

## 🎯 PROBLEMA
```json
{"error":"service not activated","code":"SETUP_REQUIRED"}
```

## ✅ SOLUÇÃO (COPIAR E COLAR)

```bash
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

docker restart e793bd3d196c && sleep 30 && curl https://evogo-evo-auth.ku83to.easypanel.host/
```

## 🎉 PRONTO!

Se não aparecer mais `SETUP_REQUIRED`, funcionou! 🚀

---

## 📚 DOCUMENTAÇÃO COMPLETA

- `README-SOLUCAO-AUTH.md` - Visão geral completa
- `ACAO-IMEDIATA-RESOLVER-AUTH.md` - Guia detalhado
- `EXPLICACAO-FIX-LICENSING.md` - Explicação técnica
