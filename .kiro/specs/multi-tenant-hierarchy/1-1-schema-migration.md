# Story 1.1: Schema Migration and Models

Status: review

## Story

As a System Administrator,
I want to add the `account_id` field to all resource tables and their respective domain models,
so that the foundation for multi-tenant data isolation is established.

## Acceptance Criteria

1. **Given** the database schema for resources (e.g. `evo_core_agents`),
   **When** the migration is executed,
   **Then** a new `account_id` column of type UUID must be added to the core resource tables.

2. **Given** the `evo_core_agents` table,
   **When** the migration runs,
   **Then** the existing `UNIQUE(name)` constraint must be dropped and replaced with `UNIQUE(account_id, name)`.

3. **Given** the Domain Models in Go,
   **When** a developer inspects them,
   **Then** the `AccountID` field of type `uuid.UUID` must be present and correctly mapped with GORM tags.

## Tasks / Subtasks

- [x] Task 1: Create Database Migration (AC: 1, 2)
  - [x] Create a new `golang-migrate` up/down SQL file.
  - [x] Add `account_id` UUID column to all necessary resource tables (e.g., `evo_core_agents`).
  - [x] Drop `UNIQUE(name)` on `evo_core_agents` and create `UNIQUE(account_id, name)`.
- [x] Task 2: Update Domain Models (AC: 3)
  - [x] Add `AccountID uuid.UUID` to `Agent` model in `pkg/agent/model/agent.go`.
  - [x] Update other relevant resource models to include `AccountID`.

## Dev Notes

- **Relevant Architecture Patterns:** GORM is used for database interaction. `golang-migrate` is used for schema migrations.
- **Source tree components to touch:** `migrations/*.sql`, `pkg/*/model/*.go`.
- **References:** [Source: docs/multi-tenancy.md#Requirements], [Source: .kiro/specs/multi-tenant-hierarchy/requirements.md#FR1].

### Project Structure Notes

- Alignment with unified project structure (paths, modules, naming)
- Detected conflicts or variances (with rationale)

## Dev Agent Record

### Agent Model Used

Gemini 2.5 Pro

### Debug Log References

### Completion Notes List

- Database migrations 000016 up/down created successfully.
- AccountID field added to 7 GORM models (Agent, CustomTool, ApiKey, Folder, FolderShare, CustomMcpServer, AgentIntegration) including their Base and Response structs.

### File List

- `migrations/000016_add_account_id_multi_tenant.up.sql`
- `migrations/000016_add_account_id_multi_tenant.down.sql`
- `pkg/agent/model/agent.go`
- `pkg/custom_tool/model/custom_tool.go`
- `pkg/api_key/model/api_key.go`
- `pkg/folder/model/folder.go`
- `pkg/folder_share/model/folder_share.go`
- `pkg/custom_mcp_server/model/custom_mcp_server.go`
- `pkg/agent_integration/model/agent_integration.go`
