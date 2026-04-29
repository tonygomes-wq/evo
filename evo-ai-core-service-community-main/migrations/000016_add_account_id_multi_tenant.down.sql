-- Revert unique constraint on evo_core_agents
ALTER TABLE evo_core_agents DROP CONSTRAINT IF EXISTS evo_core_agents_account_id_name_key;
ALTER TABLE evo_core_agents ADD CONSTRAINT evo_core_agents_name_key UNIQUE (name);

-- Drop account_id column from all resource tables
ALTER TABLE evo_core_agent_integrations DROP COLUMN IF EXISTS account_id;
ALTER TABLE evo_core_custom_mcp_servers DROP COLUMN IF EXISTS account_id;
ALTER TABLE evo_core_folder_shares DROP COLUMN IF EXISTS account_id;
ALTER TABLE evo_core_folders DROP COLUMN IF EXISTS account_id;
ALTER TABLE evo_core_api_keys DROP COLUMN IF EXISTS account_id;
ALTER TABLE evo_core_custom_tools DROP COLUMN IF EXISTS account_id;
ALTER TABLE evo_core_agents DROP COLUMN IF EXISTS account_id;
