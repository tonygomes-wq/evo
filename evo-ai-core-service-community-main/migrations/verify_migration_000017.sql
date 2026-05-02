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

-- Check if default account exists (Skipped - managed by EvoAuth)

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

-- Check if foreign key constraints exist (Skipped - accounts managed externally)

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

-- Verify default account exists (Skipped - accounts managed externally)

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

-- Verify foreign key constraints (Skipped - accounts managed externally)

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

-- Count records per account (Skipped - accounts managed externally)
\echo '========================================='
\echo 'VERIFICATION COMPLETE'
\echo '========================================='
