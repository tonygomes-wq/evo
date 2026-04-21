-- Script para marcar todas as migrações problemáticas como executadas
-- Execute este script no banco de dados evo_community

-- Conectar ao banco correto (se necessário)
\c evo_community

-- Criar tabela schema_migrations se não existir
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(255) PRIMARY KEY
);

-- Marcar migrações como executadas
INSERT INTO schema_migrations (version) VALUES ('20251114150000') ON CONFLICT DO NOTHING;
INSERT INTO schema_migrations (version) VALUES ('20251117132621') ON CONFLICT DO NOTHING;
INSERT INTO schema_migrations (version) VALUES ('20251117132725') ON CONFLICT DO NOTHING;

-- Verificar migrações inseridas
SELECT * FROM schema_migrations WHERE version IN ('20251114150000', '20251117132621', '20251117132725') ORDER BY version;
