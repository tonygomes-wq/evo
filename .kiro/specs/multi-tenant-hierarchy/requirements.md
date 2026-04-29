# Requirements Document: Multi-Tenancy Hierárquico

## Introduction

Este documento especifica os requisitos para implementação de um sistema de **multi-tenancy hierárquico com 3 níveis de acesso** no EvoAI Core Service. O sistema atualmente não possui isolamento de dados por tenant - todos os usuários autenticados compartilham os mesmos dados. A implementação garantirá isolamento completo de dados entre tenants (accounts), com hierarquia de permissões entre Super Admin, Account Owner e Account User.

O sistema utilizará a integração existente com EvoAuth Service, que já fornece informações de accounts do usuário, e implementará filtros automáticos baseados em `account_id` em todas as operações de banco de dados.

## Glossary

- **System**: EvoAI Core Service (microserviço Go)
- **Tenant**: Uma account (cliente/organização) isolada no sistema
- **Account**: Entidade de tenant gerenciada pelo Evo CRM
- **Super_Admin**: Usuário com acesso global a todas as accounts
- **Account_Owner**: Usuário proprietário de uma account específica
- **Account_User**: Usuário com acesso limitado dentro de uma account
- **Resource**: Qualquer entidade do sistema (agent, tool, folder, api_key, mcp_server)
- **Repository**: Camada de acesso a dados (GORM)
- **Middleware**: Interceptador de requisições HTTP
- **EvoAuth**: Serviço externo de autenticação
- **Context**: Contexto da requisição HTTP (Gin framework)
- **Migration**: Script de alteração de schema do banco de dados
- **Tenant_Context**: Informações de tenant injetadas no contexto da requisição
- **Cross_Tenant_Access**: Acesso a dados de outra account
- **Isolation**: Separação completa de dados entre tenants
- **Cascade_Delete**: Deleção automática de recursos dependentes

## Requirements

### Requirement 1: Database Schema Multi-Tenancy

**User Story:** As a system architect, I want all resource tables to include account_id foreign key, so that data can be isolated by tenant at the database level.

#### Acceptance Criteria

1. THE System SHALL add account_id column (UUID NOT NULL) to evo_core_agents table with foreign key to accounts(id) and ON DELETE CASCADE
2. THE System SHALL add account_id column (UUID NOT NULL) to evo_core_custom_tools table with foreign key to accounts(id) and ON DELETE CASCADE
3. THE System SHALL add account_id column (UUID NOT NULL) to evo_core_folders table with foreign key to accounts(id) and ON DELETE CASCADE
4. THE System SHALL add account_id column (UUID NOT NULL) to evo_core_api_keys table with foreign key to accounts(id) and ON DELETE CASCADE
5. THE System SHALL add account_id column (UUID NOT NULL) to evo_core_custom_mcp_servers table with foreign key to accounts(id) and ON DELETE CASCADE
6. THE System SHALL add account_id column (UUID NOT NULL) to evo_core_folder_shares table with foreign key to accounts(id) and ON DELETE CASCADE
7. THE System SHALL add account_id column (UUID NOT NULL) to evo_core_agent_integrations table with foreign key to accounts(id) and ON DELETE CASCADE
8. THE System SHALL create composite index on (account_id, id) for evo_core_agents table
9. THE System SHALL create composite index on (account_id, name) for evo_core_agents table
10. THE System SHALL create composite index on (account_id, id) for evo_core_custom_tools table
11. THE System SHALL create composite index on (account_id, id) for evo_core_folders table
12. THE System SHALL create composite index on (account_id, id) for evo_core_api_keys table
13. THE System SHALL create composite index on (account_id, id) for evo_core_custom_mcp_servers table
14. THE System SHALL create composite index on (account_id, id) for evo_core_folder_shares table
15. THE System SHALL create composite index on (account_id, id) for evo_core_agent_integrations table

### Requirement 2: Tenant Context Middleware

**User Story:** As a developer, I want a middleware that extracts and validates account_id from authenticated user, so that every request has tenant context available.

#### Acceptance Criteria

1. WHEN a request is authenticated, THE Middleware SHALL extract accounts list from EvoAuth response
2. IF accounts list is empty, THEN THE Middleware SHALL return HTTP 403 with error message "No account associated with user"
3. WHEN multiple accounts exist for user, THE Middleware SHALL use the first active account as default tenant
4. WHERE X-Account-Id header is provided, THE Middleware SHALL validate that user has access to specified account
5. IF X-Account-Id is invalid or user lacks access, THEN THE Middleware SHALL return HTTP 403 with error message "Invalid or unauthorized account access"
6. WHEN account_id is validated, THE Middleware SHALL inject account_id into request Context
7. THE Middleware SHALL inject account_status into request Context
8. THE Middleware SHALL inject user_role into request Context for authorization checks
9. THE Middleware SHALL execute after EvoAuth middleware and before route handlers
10. FOR ALL protected routes, THE Middleware SHALL be applied automatically

### Requirement 3: Super Admin Bypass

**User Story:** As a Super Admin, I want to access data from any account, so that I can manage the entire system and troubleshoot issues.

#### Acceptance Criteria

1. WHEN user role is "super_admin", THE System SHALL allow access to resources from any account
2. WHEN Super_Admin accesses cross-tenant data, THE System SHALL log the access with user_id, target_account_id, resource_type, resource_id, and timestamp
3. WHERE X-Account-Id header is provided by Super_Admin, THE System SHALL use specified account_id for queries
4. IF X-Account-Id header is not provided by Super_Admin, THEN THE System SHALL return data from all accounts
5. THE System SHALL expose GET /api/v1/admin/accounts endpoint to list all accounts (Super_Admin only)
6. THE System SHALL expose GET /api/v1/admin/accounts/:id/stats endpoint to view account statistics (Super_Admin only)
7. THE System SHALL expose POST /api/v1/admin/accounts endpoint to create new accounts (Super_Admin only)
8. THE System SHALL expose PATCH /api/v1/admin/accounts/:id/status endpoint to enable/disable accounts (Super_Admin only)
9. WHEN Super_Admin creates a resource, THE System SHALL require X-Account-Id header to specify target account
10. IF Super_Admin attempts to create resource without X-Account-Id, THEN THE System SHALL return HTTP 400 with error message "X-Account-Id header required for Super Admin operations"

### Requirement 4: Account Owner Permissions

**User Story:** As an Account Owner, I want full control over my account's data and users, so that I can manage my organization effectively.

#### Acceptance Criteria

1. WHEN user role is "account_owner", THE System SHALL grant full access to all resources within user's account
2. THE System SHALL allow Account_Owner to create, read, update, and delete any resource in their account
3. THE System SHALL expose GET /api/v1/account/users endpoint to list users in Account_Owner's account
4. THE System SHALL expose POST /api/v1/account/users endpoint to invite users to Account_Owner's account
5. THE System SHALL expose PATCH /api/v1/account/users/:id/role endpoint to change user roles within account
6. THE System SHALL expose DELETE /api/v1/account/users/:id endpoint to remove users from account
7. THE System SHALL expose GET /api/v1/account/stats endpoint to view Account_Owner's account statistics
8. WHEN Account_Owner attempts cross-tenant access, THE System SHALL return HTTP 403 with error message "Access denied to resources outside your account"
9. THE System SHALL prevent Account_Owner from accessing Super_Admin endpoints
10. THE System SHALL allow Account_Owner to assign roles: "viewer", "editor", "account_admin" to Account_Users

### Requirement 5: Account User Permissions

**User Story:** As an Account User, I want to access resources based on my assigned permissions, so that I can perform my job functions within the account.

#### Acceptance Criteria

1. WHEN user role is "account_user", THE System SHALL enforce permission-based access control
2. WHERE user has "viewer" permission, THE System SHALL allow only read operations (GET endpoints)
3. WHERE user has "editor" permission, THE System SHALL allow read and write operations (GET, POST, PUT, PATCH)
4. WHERE user has "account_admin" permission, THE System SHALL allow all operations except user management
5. IF Account_User attempts unauthorized operation, THEN THE System SHALL return HTTP 403 with error message "Insufficient permissions for this operation"
6. THE System SHALL prevent Account_User from accessing resources outside their account
7. THE System SHALL prevent Account_User from accessing admin endpoints
8. THE System SHALL prevent Account_User from accessing account management endpoints
9. WHEN Account_User creates a resource, THE System SHALL automatically assign their account_id
10. THE System SHALL expose GET /api/v1/account/my-permissions endpoint to view user's current permissions

### Requirement 6: Repository Layer Tenant Filtering

**User Story:** As a developer, I want all repository queries to automatically filter by account_id, so that tenant isolation is enforced at the data access layer.

#### Acceptance Criteria

1. WHEN Repository executes FindAll query, THE Repository SHALL add WHERE account_id = ? filter from Context
2. WHEN Repository executes FindByID query, THE Repository SHALL add AND account_id = ? filter from Context
3. WHEN Repository executes Create operation, THE Repository SHALL inject account_id from Context into new record
4. WHEN Repository executes Update operation, THE Repository SHALL verify account_id matches Context before updating
5. WHEN Repository executes Delete operation, THE Repository SHALL verify account_id matches Context before deleting
6. IF account_id in Context does not match record's account_id, THEN THE Repository SHALL return error "Resource not found"
7. WHEN user is Super_Admin with no X-Account-Id header, THE Repository SHALL omit account_id filter
8. WHEN user is Super_Admin with X-Account-Id header, THE Repository SHALL filter by specified account_id
9. THE Repository SHALL apply account_id filter to all custom queries and search operations
10. FOR ALL repository methods, THE Repository SHALL extract account_id from Context using helper function

### Requirement 7: Model Updates

**User Story:** As a developer, I want all domain models to include AccountID field, so that tenant association is explicit in the codebase.

#### Acceptance Criteria

1. THE System SHALL add AccountID field (uuid.UUID) to Agent model with gorm tag "type:uuid;not null;index"
2. THE System SHALL add AccountID field (uuid.UUID) to CustomTool model with gorm tag "type:uuid;not null;index"
3. THE System SHALL add AccountID field (uuid.UUID) to Folder model with gorm tag "type:uuid;not null;index"
4. THE System SHALL add AccountID field (uuid.UUID) to APIKey model with gorm tag "type:uuid;not null;index"
5. THE System SHALL add AccountID field (uuid.UUID) to CustomMCPServer model with gorm tag "type:uuid;not null;index"
6. THE System SHALL add AccountID field (uuid.UUID) to FolderShare model with gorm tag "type:uuid;not null;index"
7. THE System SHALL add AccountID field (uuid.UUID) to AgentIntegration model with gorm tag "type:uuid;not null;index"
8. THE System SHALL include AccountID in JSON serialization for all models
9. THE System SHALL exclude AccountID from user input validation (auto-injected from Context)
10. THE System SHALL validate AccountID is not empty before database operations

### Requirement 8: Data Migration Strategy

**User Story:** As a system administrator, I want existing data to be migrated to a default account, so that the system can transition to multi-tenancy without data loss.

#### Acceptance Criteria

1. THE System SHALL create a migration script to add account_id columns to all tables
2. THE System SHALL create a default account with name "Default Account" and status "active" if no accounts exist
3. WHEN account_id column is added, THE System SHALL set all existing records to default account's ID
4. THE System SHALL verify all records have valid account_id before applying NOT NULL constraint
5. THE System SHALL create a rollback migration to remove account_id columns
6. THE System SHALL log migration progress with count of records updated per table
7. IF migration fails on any table, THEN THE System SHALL rollback all changes and log error details
8. THE System SHALL create backup recommendation documentation before migration
9. THE System SHALL provide SQL script to manually assign records to specific accounts post-migration
10. THE System SHALL validate foreign key constraints after migration completes

### Requirement 9: Cross-Tenant Access Prevention

**User Story:** As a security engineer, I want the system to prevent unauthorized cross-tenant data access, so that tenant data remains isolated and secure.

#### Acceptance Criteria

1. WHEN user attempts to access resource with different account_id, THE System SHALL return HTTP 404 with message "Resource not found"
2. THE System SHALL never expose account_id in error messages to non-admin users
3. WHEN user attempts to update resource with different account_id, THE System SHALL return HTTP 404 with message "Resource not found"
4. WHEN user attempts to delete resource with different account_id, THE System SHALL return HTTP 404 with message "Resource not found"
5. THE System SHALL prevent account_id modification in update requests (immutable field)
6. IF user provides account_id in create request body, THE System SHALL ignore it and use Context value
7. THE System SHALL validate all foreign key references belong to same account_id
8. WHEN creating resource with foreign key (e.g., folder_id), THE System SHALL verify referenced resource belongs to user's account
9. IF foreign key references cross-tenant resource, THEN THE System SHALL return HTTP 400 with message "Referenced resource not found in your account"
10. THE System SHALL log all failed cross-tenant access attempts with user_id, attempted_account_id, and resource_id

### Requirement 10: Account Cascade Deletion

**User Story:** As a Super Admin, I want all account resources to be deleted when an account is deleted, so that no orphaned data remains in the system.

#### Acceptance Criteria

1. WHEN account is deleted, THE System SHALL automatically delete all evo_core_agents records with matching account_id
2. WHEN account is deleted, THE System SHALL automatically delete all evo_core_custom_tools records with matching account_id
3. WHEN account is deleted, THE System SHALL automatically delete all evo_core_folders records with matching account_id
4. WHEN account is deleted, THE System SHALL automatically delete all evo_core_api_keys records with matching account_id
5. WHEN account is deleted, THE System SHALL automatically delete all evo_core_custom_mcp_servers records with matching account_id
6. WHEN account is deleted, THE System SHALL automatically delete all evo_core_folder_shares records with matching account_id
7. WHEN account is deleted, THE System SHALL automatically delete all evo_core_agent_integrations records with matching account_id
8. THE System SHALL use database-level CASCADE DELETE constraints for automatic cleanup
9. THE System SHALL log account deletion with account_id, deleted_by user_id, and timestamp
10. THE System SHALL expose GET /api/v1/admin/accounts/:id/resources-count endpoint to preview deletion impact (Super_Admin only)

### Requirement 11: Rate Limiting Per Tenant

**User Story:** As a system administrator, I want rate limiting applied per account, so that one tenant cannot exhaust system resources affecting others.

#### Acceptance Criteria

1. THE System SHALL implement rate limiting based on account_id instead of IP address
2. THE System SHALL allow configurable requests-per-second limit per account via RATE_LIMIT_ACCOUNT_RPS environment variable
3. THE System SHALL allow configurable burst limit per account via RATE_LIMIT_ACCOUNT_BURST environment variable
4. WHEN account exceeds rate limit, THE System SHALL return HTTP 429 with message "Rate limit exceeded for your account"
5. THE System SHALL include Retry-After header in 429 responses indicating seconds until limit resets
6. THE System SHALL exempt Super_Admin from account-based rate limiting
7. THE System SHALL maintain separate rate limit counters for each account
8. THE System SHALL reset rate limit counters every second (sliding window)
9. THE System SHALL log rate limit violations with account_id, endpoint, and timestamp
10. THE System SHALL expose GET /api/v1/admin/accounts/:id/rate-limit-stats endpoint to view account's rate limit usage (Super_Admin only)

### Requirement 12: Audit Logging for Multi-Tenancy

**User Story:** As a compliance officer, I want all tenant-related operations logged, so that we can audit access patterns and detect security issues.

#### Acceptance Criteria

1. WHEN Super_Admin accesses cross-tenant data, THE System SHALL log entry with level "INFO", user_id, user_email, target_account_id, resource_type, resource_id, action, and timestamp
2. WHEN user attempts unauthorized cross-tenant access, THE System SHALL log entry with level "WARN", user_id, user_account_id, attempted_account_id, resource_type, resource_id, and timestamp
3. WHEN account is created, THE System SHALL log entry with level "INFO", created_by user_id, new_account_id, account_name, and timestamp
4. WHEN account is deleted, THE System SHALL log entry with level "INFO", deleted_by user_id, account_id, account_name, resources_deleted_count, and timestamp
5. WHEN account status changes, THE System SHALL log entry with level "INFO", changed_by user_id, account_id, old_status, new_status, and timestamp
6. WHEN Account_Owner modifies user roles, THE System SHALL log entry with level "INFO", owner_id, target_user_id, old_role, new_role, account_id, and timestamp
7. THE System SHALL write audit logs to dedicated log stream or file separate from application logs
8. THE System SHALL format audit logs as structured JSON for parsing and analysis
9. THE System SHALL include request_id in all audit log entries for request tracing
10. THE System SHALL expose GET /api/v1/admin/audit-logs endpoint with filtering by account_id, user_id, action, date_range (Super_Admin only)

### Requirement 13: Multi-Tenancy Testing

**User Story:** As a QA engineer, I want comprehensive tests for tenant isolation, so that we can verify no data leakage occurs between tenants.

#### Acceptance Criteria

1. THE System SHALL include integration test that creates resources in Account A and verifies Account B user cannot access them
2. THE System SHALL include integration test that verifies Super_Admin can access resources from multiple accounts
3. THE System SHALL include integration test that verifies Account_Owner cannot access resources from other accounts
4. THE System SHALL include integration test that verifies account_id filter is applied to all repository queries
5. THE System SHALL include integration test that verifies foreign key references are validated within same account
6. THE System SHALL include integration test that verifies cascade deletion removes all account resources
7. THE System SHALL include unit test for tenant middleware that validates account extraction and injection
8. THE System SHALL include unit test for repository layer that verifies account_id filtering logic
9. THE System SHALL include security test that attempts SQL injection via account_id parameter
10. THE System SHALL include load test that verifies rate limiting works correctly per account under concurrent requests

### Requirement 14: Documentation and Migration Guide

**User Story:** As a developer, I want comprehensive documentation for multi-tenancy implementation, so that I can understand and maintain the system.

#### Acceptance Criteria

1. THE System SHALL include README section explaining multi-tenancy architecture and hierarchy levels
2. THE System SHALL include migration guide with step-by-step instructions for upgrading existing deployments
3. THE System SHALL include API documentation showing X-Account-Id header usage for Super_Admin
4. THE System SHALL include code examples for adding account_id filtering to new repositories
5. THE System SHALL include diagram showing request flow through tenant middleware and repository layer
6. THE System SHALL include troubleshooting guide for common multi-tenancy issues
7. THE System SHALL include environment variable documentation for rate limiting configuration
8. THE System SHALL include security best practices document for tenant isolation
9. THE System SHALL include rollback procedure documentation if migration fails
10. THE System SHALL include FAQ section addressing common multi-tenancy questions

### Requirement 15: Performance Optimization

**User Story:** As a system administrator, I want multi-tenancy implementation to maintain system performance, so that response times remain acceptable under load.

#### Acceptance Criteria

1. THE System SHALL execute queries with account_id filter using composite indexes (account_id, id)
2. WHEN listing resources, THE System SHALL use EXPLAIN ANALYZE to verify index usage on account_id
3. THE System SHALL cache account information in Context to avoid repeated EvoAuth calls
4. THE System SHALL use connection pooling with minimum 10 and maximum 100 connections
5. THE System SHALL implement pagination for all list endpoints with default page size 50 and maximum 200
6. THE System SHALL add database query timeout of 30 seconds to prevent long-running queries
7. THE System SHALL monitor query performance and log slow queries (>1 second) with account_id and query details
8. THE System SHALL use prepared statements for all parameterized queries to prevent SQL injection and improve performance
9. THE System SHALL implement response caching for frequently accessed resources with 5-minute TTL
10. THE System SHALL expose GET /api/v1/admin/performance/slow-queries endpoint to view slow query log (Super_Admin only)

