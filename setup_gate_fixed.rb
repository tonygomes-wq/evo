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
