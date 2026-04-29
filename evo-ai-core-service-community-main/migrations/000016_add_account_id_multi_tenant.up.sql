-- Add account_id to all resource tables
ALTER TABLE evo_core_agents ADD COLUMN account_id UUID;
ALTER TABLE evo_core_custom_tools ADD COLUMN account_id UUID;
ALTER TABLE evo_core_api_keys ADD COLUMN account_id UUID;
ALTER TABLE evo_core_folders ADD COLUMN account_id UUID;
ALTER TABLE evo_core_folder_shares ADD COLUMN account_id UUID;
ALTER TABLE evo_core_custom_mcp_servers ADD COLUMN account_id UUID;
ALTER TABLE evo_core_agent_integrations ADD COLUMN account_id UUID;

-- Update unique constraint on evo_core_agents
ALTER TABLE evo_core_agents DROP CONSTRAINT IF EXISTS evo_core_agents_name_key;
ALTER TABLE evo_core_agents ADD CONSTRAINT evo_core_agents_account_id_name_key UNIQUE (account_id, name);

-- Note: We are allowing NULL account_id for now to support backward compatibility with existing data.
-- A subsequent migration will populate account_id for existing records and enforce NOT NULL if required.
