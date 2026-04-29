# Story 1.2: Tenant Middleware

Status: review

## Story

As a System Administrator,
I want a middleware to extract the tenant ID (`account_id`) from the authentication token and inject it into the request context,
so that downstream repositories and services can isolate data automatically based on the tenant.

## Acceptance Criteria

1. **Given** an authenticated request,
   **When** it passes through the middleware stack,
   **Then** a new `TenantMiddleware` must extract the `account_id` (from the decoded JWT via EvoAuth) and inject it into the Gin context.

2. **Given** any handler or service logic,
   **When** it needs the current tenant ID,
   **Then** a helper function (e.g., `GetTenantID(c *gin.Context) (uuid.UUID, error)`) must be available to retrieve it.

3. **Given** a request without a valid `account_id` in the context,
   **When** the helper function is called,
   **Then** it must return a specific error indicating that the tenant context is missing.

## Tasks / Subtasks

- [x] Task 1: Create Tenant Middleware (AC: 1)
  - [x] Create `internal/middleware/tenant.go`.
  - [x] Implement `TenantMiddleware` to extract `account_id` from the `evoAuth` token data (e.g., `tokenDataResponse.User.Accounts` or similar logic in `evo_auth.go`).
- [x] Task 2: Create Context Helpers (AC: 2, 3)
  - [x] Implement `GetTenantID` to safely retrieve and parse the UUID from the context.
  - [x] Return appropriate errors if missing or invalid.
- [x] Task 3: Integrate Middleware
  - [x] Register `TenantMiddleware` in the main router immediately after `EvoAuthMiddleware`.

## Dev Notes

- **Relevant Architecture Patterns:** The project uses `gin-gonic/gin`, not Echo. Ensure all middleware and helpers use `*gin.Context`.
- **Source tree components to touch:** `internal/middleware/tenant.go`, `internal/api/router.go` (or wherever the global routes are defined), `internal/middleware/evo_auth.go` (to ensure the account_id is properly passed down from the auth service).
- **References:** [Source: docs/multi-tenancy.md], [Source: .kiro/specs/multi-tenant-hierarchy/requirements.md#FR2-FR3].

### Project Structure Notes

- Keep the helper function close to the middleware or in an `internal/utils/contextutils` package.

## Dev Agent Record

### Agent Model Used

Gemini 2.5 Pro

### Debug Log References

### Completion Notes List

- Updated `EvoAuthMiddleware` to inject user `Accounts` into the Gin context.
- Created `TenantMiddleware` that extracts `Accounts`, defaults to the first account, but also respects an optional `X-Tenant-ID` header.
- Implemented `GetTenantID` context helper.
- Registered `TenantMiddleware` in `cmd/api/main.go` inside the `v1` group router right after `EvoAuthMiddleware`.

### File List

- `internal/middleware/evo_auth.go`
- `internal/middleware/tenant.go`
- `cmd/api/main.go`
