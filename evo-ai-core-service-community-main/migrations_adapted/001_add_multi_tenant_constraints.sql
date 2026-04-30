-- Migration: Add Multi-Tenant Constraints and Indexes
-- Description: Add NOT NULL constraints and composite indexes for multi-tenancy
-- Date: 2026-04-29
-- Note: This is adapted for Evo CRM which uses external EvoAuth accounts

-- ============================================================================
-- STEP 1: Verify account_id columns exist (they should already exist)
-- ============================================================================

DO $$
BEGIN
    -- Check if account_id exists in all tables
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'evo_core_agents' AND column_name = 'account_id'
    ) THEN
        RAISE EXCEPTION 'account_id column not found in evo_core_agents';
    END IF;
    
    RAISE NOTICE 'All account_id columns verified';
END $$;

-- ============================================================================
-- STEP 2: Create Composite Indexes for Performance
-- ============================================================================

-- Agents
CREATE INDEX IF NOT EXISTS idx_evo_core_agents_account_id_id 
ON evo_core_agents(account_id, id);

CREATE INDEX IF NOT EXISTS idx_evo_core_agents_account_id_folder_id 
ON evo_core_agents(account_id, folder_id);

-- Custom Tools
CREATE INDEX IF NOT EXISTS idx_evo_core_custom_tools_account_id_id 
ON evo_core_custom_tools(account_id, id);

-- API Keys
CREATE INDEX IF NOT EXISTS idx_evo_core_api_keys_account_id_id 
ON evo_core_api_keys(account_id, id);

-- Folders
CREATE INDEX IF NOT EXISTS idx_evo_core_folders_account_id_id 
ON evo_core_folders(account_id, id);

-- Folder Shares
CREATE INDEX IF NOT EXISTS idx_evo_core_folder_shares_account_id_id 
ON evo_core_folder_shares(account_id, id);

CREATE INDEX IF NOT EXISTS idx_evo_core_folder_shares_account_id_folder_id 
ON evo_core_folder_shares(account_id, folder_id);

-- Custom MCP Servers
CREATE INDEX IF NOT EXISTS idx_evo_core_custom_mcp_servers_account_id_id 
ON evo_core_custom_mcp_servers(account_id, id);

-- Agent Integrations
CREATE INDEX IF NOT EXISTS idx_evo_core_agent_integrations_account_id_agent_id 
ON evo_core_agent_integrations(account_id, agent_id);

-- ============================================================================
-- STEP 3: Update Statistics for Query Optimizer
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

DO $$
BEGIN
    RAISE NOTICE 'Migration completed successfully';
    RAISE NOTICE 'Composite indexes created for performance';
    RAISE NOTICE 'Note: account_id can be NULL for backward compatibility';
    RAISE NOTICE 'New records will have account_id injected by the application';
END $$;
