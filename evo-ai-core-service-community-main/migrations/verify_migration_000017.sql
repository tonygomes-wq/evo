-- Verification Script for Migration 000017
-- Run this BEFORE applying the migration to check current state
-- Run this AFTER applying the migration to verify success

-- ============================================================================
-- PRE-MIGRATION CHECKS
-- ============================================================================

\echo '========================================='
\echo 'PRE-MIGRATION STATE CHECK'
\echo '========================================='
\echo ''

-- Check if default account exists
\echo 'Checking if default account exists...'
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM accounts WHERE id = '00000000-0000-0000-0000-000000000001')
        THEN '✓ Default account already exists'
        ELSE '✗ Default account does NOT exist (will be created)'
    END AS default_account_status;

\echo ''

-- Count orphaned records (account_id IS NULL)
\echo 'Counting orphaned records (account_id IS NULL)...'
SELECT 
    'evo_core_agents' AS table_name,
    COUNT(*) AS orphaned_count
FROM evo_core_agents 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_custom_tools',
    COUNT(*)
FROM evo_core_custom_tools 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_api_keys',
    COUNT(*)
FROM evo_core_api_keys 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_folders',
    COUNT(*)
FROM evo_core_folders 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_folder_shares',
    COUNT(*)
FROM evo_core_folder_shares 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_custom_mcp_servers',
    COUNT(*)
FROM evo_core_custom_mcp_servers 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_agent_integrations',
    COUNT(*)
FROM evo_core_agent_integrations 
WHERE account_id IS NULL;

\echo ''

-- Check if foreign key constraints exist
\echo 'Checking existing foreign key constraints...'
SELECT 
    conname AS constraint_name,
    conrelid::regclass AS table_name
FROM pg_constraint
WHERE conname LIKE 'fk_%_account_id'
ORDER BY table_name;

\echo ''

-- Check if NOT NULL constraints exist
\echo 'Checking NOT NULL constraints on account_id...'
SELECT 
    table_name,
    column_name,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND column_name = 'account_id'
  AND table_name LIKE 'evo_core_%'
ORDER BY table_name;

\echo ''

-- Check existing indexes
\echo 'Checking existing composite indexes...'
SELECT 
    schemaname,
    tablename,
    indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE '%account_id%'
ORDER BY tablename, indexname;

\echo ''
\echo '========================================='
\echo 'POST-MIGRATION VERIFICATION'
\echo '========================================='
\echo ''

-- Verify default account exists
\echo 'Verifying default account...'
SELECT 
    id,
    name,
    status,
    created_at
FROM accounts
WHERE id = '00000000-0000-0000-0000-000000000001';

\echo ''

-- Verify NO orphaned records remain
\echo 'Verifying NO orphaned records remain...'
SELECT 
    'evo_core_agents' AS table_name,
    COUNT(*) AS orphaned_count,
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ FAILED' END AS status
FROM evo_core_agents 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_custom_tools',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ FAILED' END
FROM evo_core_custom_tools 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_api_keys',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ FAILED' END
FROM evo_core_api_keys 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_folders',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ FAILED' END
FROM evo_core_folders 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_folder_shares',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ FAILED' END
FROM evo_core_folder_shares 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_custom_mcp_servers',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ FAILED' END
FROM evo_core_custom_mcp_servers 
WHERE account_id IS NULL
UNION ALL
SELECT 
    'evo_core_agent_integrations',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✓ OK' ELSE '✗ FAILED' END
FROM evo_core_agent_integrations 
WHERE account_id IS NULL;

\echo ''

-- Verify foreign key constraints
\echo 'Verifying foreign key constraints...'
SELECT 
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    '✓ OK' AS status
FROM pg_constraint
WHERE conname IN (
    'fk_agents_account_id',
    'fk_custom_tools_account_id',
    'fk_api_keys_account_id',
    'fk_folders_account_id',
    'fk_folder_shares_account_id',
    'fk_custom_mcp_servers_account_id',
    'fk_agent_integrations_account_id'
)
ORDER BY table_name;

\echo ''

-- Verify NOT NULL constraints
\echo 'Verifying NOT NULL constraints...'
SELECT 
    table_name,
    column_name,
    is_nullable,
    CASE WHEN is_nullable = 'NO' THEN '✓ OK' ELSE '✗ FAILED' END AS status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND column_name = 'account_id'
  AND table_name LIKE 'evo_core_%'
ORDER BY table_name;

\echo ''

-- Verify composite indexes
\echo 'Verifying composite indexes...'
SELECT 
    tablename,
    indexname,
    '✓ OK' AS status
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_evo_core_%_account_id%'
ORDER BY tablename, indexname;

\echo ''

-- Count records per account
\echo 'Records per account distribution...'
SELECT 
    a.name AS account_name,
    a.id AS account_id,
    (SELECT COUNT(*) FROM evo_core_agents WHERE account_id = a.id) AS agents,
    (SELECT COUNT(*) FROM evo_core_custom_tools WHERE account_id = a.id) AS tools,
    (SELECT COUNT(*) FROM evo_core_api_keys WHERE account_id = a.id) AS api_keys,
    (SELECT COUNT(*) FROM evo_core_folders WHERE account_id = a.id) AS folders,
    (SELECT COUNT(*) FROM evo_core_folder_shares WHERE account_id = a.id) AS shares,
    (SELECT COUNT(*) FROM evo_core_custom_mcp_servers WHERE account_id = a.id) AS mcp_servers,
    (SELECT COUNT(*) FROM evo_core_agent_integrations WHERE account_id = a.id) AS integrations
FROM accounts a
ORDER BY a.created_at;

\echo ''
\echo '========================================='
\echo 'VERIFICATION COMPLETE'
\echo '========================================='
