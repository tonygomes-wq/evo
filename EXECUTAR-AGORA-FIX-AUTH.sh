#!/bin/bash
# EXECUTAR NO SERVIDOR: bash EXECUTAR-AGORA-FIX-AUTH.sh

echo "🔧 Corrigindo SetupGate para Community Edition..."

# Criar o arquivo modificado dentro do container
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
      # The licensing system is not needed for the community edition
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
      # Community edition is identified by the TIER constant
      defined?(Licensing::Activation::TIER) && 
        Licensing::Activation::TIER == 'evo-ai-crm-community'
    end
  end
end
EOF

echo "✅ Arquivo modificado criado"

# Verificar se o arquivo foi criado corretamente
echo ""
echo "📄 Verificando conteúdo do arquivo..."
docker exec e793bd3d196c cat app/services/licensing/setup_gate.rb | grep -A 2 "is_community_edition"

echo ""
echo "🔄 Reiniciando container evo-auth..."
docker restart e793bd3d196c

echo "⏳ Aguardando 30 segundos para o serviço iniciar..."
sleep 30

echo ""
echo "🧪 Testando endpoint..."
curl -s https://evogo-evo-auth.ku83to.easypanel.host/ | head -c 200
echo ""

echo ""
echo "✅ PRONTO! Se não aparecer mais o erro SETUP_REQUIRED, o problema foi resolvido!"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "1. Testar login no frontend: https://evogo-evo-frontend.ku83to.easypanel.host"
echo "2. Usar credenciais: admin@macip.com.br / Admin@123456"
echo "3. Se o login funcionar, executar MARCAR-TODAS-MIGRACOES.sql no PostgreSQL"
