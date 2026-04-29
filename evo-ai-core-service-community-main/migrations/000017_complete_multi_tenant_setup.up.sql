-- Migration: Complete Multi-Tenant Setup
-- Description: Migrate existing data, add constraints, and create indexes
-- Date: 2026-04-29

-- ============================================================================
-- STEP 1: Create Default Account (if not exists)
-- ============================================================================

INSERT INTO accounts (id, name, status, created_at, updated_at)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Default Account',
    'active',
    NOW(),
    NOW()
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- STEP 2: Migrate Orphaned Data to Default Account
-- ============================================================================

-- Agents
UPDATE evo_core_agents 
SET account_id = '00000000-0000-0000-0000-000000000001'
WHERE account_id IS NULL;

-- Custom Tools
UPDATE evo_core_custom_tools 
SET account_id = '00000000-0000-0000-0000-000000000001'
WHERE account_id IS NULL;

-- API Keys
UPDATE evo_core_api_keys 
SET account_id = '00000000-0000-0000-0000-000000000001'
WHERE account_id IS NULL;

-- Folders
UPDATE evo_core_folders 
SET account_id = '00000000-0000-0000-0000-000000000001'
WHERE account_id IS NULL;

-- Folder Shares
UPDATE evo_core_folder_shares 
SET account_id = '00000000-0000-0000-0000-000000000001'
WHERE account_id IS NULL;

-- Custom MCP Servers
UPDATE evo_core_custom_mcp_servers 
SET account_id = '00000000-0000-0000-0000-000000000001'
WHERE account_id IS NULL;

-- Agent Integrations
UPDATE evo_core_agent_integrations 
SET account_id = '00000000-0000-0000-0000-000000000001'
WHERE account_id IS NULL;

-- ============================================================================
-- STEP 3: Verify No Orphaned Data Remains
-- ============================================================================

-- This will fail the migration if any NULL account_id remains
DO $$
DECLARE
    orphaned_agents INT;
    orphaned_tools INT;
    orphaned_keys INT;
    orphaned_folders INT;
    orphaned_shares INT;
    orphaned_servers INT;
    orphaned_integrations INT;
BEGIN
    SELECT COUNT(*) INTO orphaned_agents FROM evo_core_agents WHERE account_id IS NULL;
    SELECT COUNT(*) INTO orphaned_tools FROM evo_core_custom_tools WHERE account_id IS NULL;
    SELECT COUNT(*) INTO orphaned_keys FROM evo_core_api_keys WHERE account_id IS NULL;
    SELECT COUNT(*) INTO orphaned_folders FROM evo_core_folders WHERE account_id IS NULL;
    SELECT COUNT(*) INTO orphaned_shares FROM evo_core_folder_shares WHERE account_id IS NULL;
    SELECT COUNT(*) INTO orphaned_servers FROM evo_core_custom_mcp_servers WHERE account_id IS NULL;
    SELECT COUNT(*) INTO orphaned_integrations FROM evo_core_agent_integrations WHERE account_id IS NULL;
    
    IF orphaned_agents > 0 OR orphaned_tools > 0 OR orphaned_keys > 0 OR 
       orphaned_folders > 0 OR orphaned_shares > 0 OR orphaned_servers > 0 OR 
       orphaned_integrations > 0 THEN
        RAISE EXCEPTION 'Migration failed: Found orphaned records with NULL account_id';
    END IF;
END $$;

-- ============================================================================
-- STEP 4: Add Foreign Key Constraints
-- ============================================================================

-- Agents
ALTER TABLE evo_core_agents
ADD CONSTRAINT fk_agents_account_id
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

-- Custom Tools
ALTER TABLE evo_core_custom_tools
ADD CONSTRAINT fk_custom_tools_account_id
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

-- API Keys
ALTER TABLE evo_core_api_keys
ADD CONSTRAINT fk_api_keys_account_id
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

-- Folders
ALTER TABLE evo_core_folders
ADD CONSTRAINT fk_folders_account_id
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

-- Folder Shares
ALTER TABLE evo_core_folder_shares
ADD CONSTRAINT fk_folder_shares_account_id
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

-- Custom MCP Servers
ALTER TABLE evo_core_custom_mcp_servers
ADD CONSTRAINT fk_custom_mcp_servers_account_id
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

-- Agent Integrations
ALTER TABLE evo_core_agent_integrations
ADD CONSTRAINT fk_agent_integrations_account_id
FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE;

-- ============================================================================
-- STEP 5: Apply NOT NULL Constraints
-- ============================================================================

-- Agents
ALTER TABLE evo_core_agents 
ALTER COLUMN account_id SET NOT NULL;

-- Custom Tools
ALTER TABLE evo_core_custom_tools 
ALTER COLUMN account_id SET NOT NULL;

-- API Keys
ALTER TABLE evo_core_api_keys 
ALTER COLUMN account_id SET NOT NULL;

-- Folders
ALTER TABLE evo_core_folders 
ALTER COLUMN account_id SET NOT NULL;

-- Folder Shares
ALTER TABLE evo_core_folder_shares 
ALTER COLUMN account_id SET NOT NULL;

-- Custom MCP Servers
ALTER TABLE evo_core_custom_mcp_servers 
ALTER COLUMN account_id SET NOT NULL;

-- Agent Integrations
ALTER TABLE evo_core_agent_integrations 
ALTER COLUMN account_id SET NOT NULL;

-- ============================================================================
-- STEP 6: Create Composite Indexes for Performance
-- ============================================================================

-- Agents
CREATE INDEX IF NOT EXISTS idx_evo_core_agents_account_id_id 
ON evo_core_agents(account_id, id);

CREATE INDEX IF NOT EXISTS idx_evo_core_agents_account_id_name 
ON evo_core_agents(account_id, name);

CREATE INDEX IF NOT EXISTS idx_evo_core_agents_account_id_folder_id 
ON evo_core_agents(account_id, folder_id);

-- Custom Tools
CREATE INDEX IF NOT EXISTS idx_evo_core_custom_tools_account_id_id 
ON evo_core_custom_tools(account_id, id);

CREATE INDEX IF NOT EXISTS idx_evo_core_custom_tools_account_id_name 
ON evo_core_custom_tools(account_id, name);

-- API Keys
CREATE INDEX IF NOT EXISTS idx_evo_core_api_keys_account_id_id 
ON evo_core_api_keys(account_id, id);

CREATE INDEX IF NOT EXISTS idx_evo_core_api_keys_account_id_active 
ON evo_core_api_keys(account_id, is_active);

-- Folders
CREATE INDEX IF NOT EXISTS idx_evo_core_folders_account_id_id 
ON evo_core_folders(account_id, id);

CREATE INDEX IF NOT EXISTS idx_evo_core_folders_account_id_name 
ON evo_core_folders(account_id, name);

-- Folder Shares
CREATE INDEX IF NOT EXISTS idx_evo_core_folder_shares_account_id_id 
ON evo_core_folder_shares(account_id, id);

CREATE INDEX IF NOT EXISTS idx_evo_core_folder_shares_account_id_folder_id 
ON evo_core_folder_shares(account_id, folder_id);

CREATE INDEX IF NOT EXISTS idx_evo_core_folder_shares_account_id_email 
ON evo_core_folder_shares(account_id, shared_with_email);

-- Custom MCP Servers
CREATE INDEX IF NOT EXISTS idx_evo_core_custom_mcp_servers_account_id_id 
ON evo_core_custom_mcp_servers(account_id, id);

CREATE INDEX IF NOT EXISTS idx_evo_core_custom_mcp_servers_account_id_name 
ON evo_core_custom_mcp_servers(account_id, name);

-- Agent Integrations
CREATE INDEX IF NOT EXISTS idx_evo_core_agent_integrations_account_id_agent_id 
ON evo_core_agent_integrations(account_id, agent_id);

CREATE INDEX IF NOT EXISTS idx_evo_core_agent_integrations_account_id_provider 
ON evo_core_agent_integrations(account_id, agent_id, provider);

-- ============================================================================
-- STEP 7: Update Statistics for Query Optimizer
-- ============================================================================

ANALYZE evo_core_agents;
ANALYZE evo_core_custom_tools;
ANALYZE evo_core_api_keys;
ANALYZE evo_core_folders;
ANALYZE evo_core_folder_shares;
ANALYZE evo_core_custom_mcp_servers;
ANALYZE evo_core_agent_integrations;

-- ============================================================================
-- Migration Complete
-- ============================================================================

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'Migration 000017 completed successfully';
    RAISE NOTICE 'Default account created: 00000000-0000-0000-0000-000000000001';
    RAISE NOTICE 'All orphaned data migrated to default account';
    RAISE NOTICE 'Foreign key constraints applied';
    RAISE NOTICE 'NOT NULL constraints applied';
    RAISE NOTICE 'Composite indexes created for performance';
END $$;
