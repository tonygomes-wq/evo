-- Migration Rollback: Complete Multi-Tenant Setup
-- Description: Rollback constraints and indexes (data migration is NOT reversed)
-- Date: 2026-04-29
-- WARNING: This rollback does NOT restore data to NULL account_id state

-- ============================================================================
-- STEP 1: Drop Composite Indexes
-- ============================================================================

-- Agent Integrations
DROP INDEX IF EXISTS idx_evo_core_agent_integrations_account_id_provider;
DROP INDEX IF EXISTS idx_evo_core_agent_integrations_account_id_agent_id;

-- Custom MCP Servers
DROP INDEX IF EXISTS idx_evo_core_custom_mcp_servers_account_id_name;
DROP INDEX IF EXISTS idx_evo_core_custom_mcp_servers_account_id_id;

-- Folder Shares
DROP INDEX IF EXISTS idx_evo_core_folder_shares_account_id_email;
DROP INDEX IF EXISTS idx_evo_core_folder_shares_account_id_folder_id;
DROP INDEX IF EXISTS idx_evo_core_folder_shares_account_id_id;

-- Folders
DROP INDEX IF EXISTS idx_evo_core_folders_account_id_name;
DROP INDEX IF EXISTS idx_evo_core_folders_account_id_id;

-- API Keys
DROP INDEX IF EXISTS idx_evo_core_api_keys_account_id_active;
DROP INDEX IF EXISTS idx_evo_core_api_keys_account_id_id;

-- Custom Tools
DROP INDEX IF EXISTS idx_evo_core_custom_tools_account_id_name;
DROP INDEX IF EXISTS idx_evo_core_custom_tools_account_id_id;

-- Agents
DROP INDEX IF EXISTS idx_evo_core_agents_account_id_folder_id;
DROP INDEX IF EXISTS idx_evo_core_agents_account_id_name;
DROP INDEX IF EXISTS idx_evo_core_agents_account_id_id;

-- ============================================================================
-- STEP 2: Remove NOT NULL Constraints
-- ============================================================================

-- Agent Integrations
ALTER TABLE evo_core_agent_integrations 
ALTER COLUMN account_id DROP NOT NULL;

-- Custom MCP Servers
ALTER TABLE evo_core_custom_mcp_servers 
ALTER COLUMN account_id DROP NOT NULL;

-- Folder Shares
ALTER TABLE evo_core_folder_shares 
ALTER COLUMN account_id DROP NOT NULL;

-- Folders
ALTER TABLE evo_core_folders 
ALTER COLUMN account_id DROP NOT NULL;

-- API Keys
ALTER TABLE evo_core_api_keys 
ALTER COLUMN account_id DROP NOT NULL;

-- Custom Tools
ALTER TABLE evo_core_custom_tools 
ALTER COLUMN account_id DROP NOT NULL;

-- Agents
ALTER TABLE evo_core_agents 
ALTER COLUMN account_id DROP NOT NULL;

-- ============================================================================
-- STEP 3: Drop Foreign Key Constraints
-- ============================================================================

-- Agent Integrations
ALTER TABLE evo_core_agent_integrations
DROP CONSTRAINT IF EXISTS fk_agent_integrations_account_id;

-- Custom MCP Servers
ALTER TABLE evo_core_custom_mcp_servers
DROP CONSTRAINT IF EXISTS fk_custom_mcp_servers_account_id;

-- Folder Shares
ALTER TABLE evo_core_folder_shares
DROP CONSTRAINT IF EXISTS fk_folder_shares_account_id;

-- Folders
ALTER TABLE evo_core_folders
DROP CONSTRAINT IF EXISTS fk_folders_account_id;

-- API Keys
ALTER TABLE evo_core_api_keys
DROP CONSTRAINT IF EXISTS fk_api_keys_account_id;

-- Custom Tools
ALTER TABLE evo_core_custom_tools
DROP CONSTRAINT IF EXISTS fk_custom_tools_account_id;

-- Agents
ALTER TABLE evo_core_agents
DROP CONSTRAINT IF EXISTS fk_agents_account_id;

-- ============================================================================
-- STEP 4: Update Statistics
-- ============================================================================

ANALYZE evo_core_agents;
ANALYZE evo_core_custom_tools;
ANALYZE evo_core_api_keys;
ANALYZE evo_core_folders;
ANALYZE evo_core_folder_shares;
ANALYZE evo_core_custom_mcp_servers;
ANALYZE evo_core_agent_integrations;

-- ============================================================================
-- Rollback Complete
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE 'Migration 000017 rollback completed';
    RAISE NOTICE 'Foreign key constraints removed';
    RAISE NOTICE 'NOT NULL constraints removed';
    RAISE NOTICE 'Composite indexes dropped';
    RAISE NOTICE '';
    RAISE WARNING 'Data migration was NOT reversed - all records still have account_id set';
    RAISE WARNING 'Default account (00000000-0000-0000-0000-000000000001) was NOT deleted';
    RAISE WARNING 'To fully rollback, manually set account_id to NULL if needed';
END $$;
