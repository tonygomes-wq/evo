---
stepsCompleted: ["01-validate-prerequisites"]
inputDocuments: [
  ".kiro/specs/multi-tenant-hierarchy/requirements.md",
  "docs/architecture.md",
  "docs/multi-tenancy.md",
  "docs/project-overview.md"
]
---

# Evo CRM Community - Multi-Tenant Hierarchy - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Evo CRM Community - Multi-Tenant Hierarchy, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: Database Schema Multi-Tenancy
FR2: Tenant Context Middleware
FR3: Super Admin Bypass
FR4: Account Owner Permissions
FR5: Account User Permissions
FR6: Repository Layer Tenant Filtering
FR7: Model Updates
FR8: Data Migration Strategy
FR9: Cross-Tenant Access Prevention
FR10: Account Cascade Deletion

### NonFunctional Requirements

NFR1: Rate Limiting Per Tenant
NFR2: Audit Logging for Multi-Tenancy
NFR3: Multi-Tenancy Testing
NFR4: Documentation and Migration Guide
NFR5: Performance Optimization

### Additional Requirements

- Drop UNIQUE(name) index on evo_core_agents and replace with UNIQUE(account_id, name)
- Register tenant middleware immediately after EvoAuthMiddleware in the Gin router.
- Boundaries: Ensure proper separation of concerns between EvoAuth and EvoCore for user management endpoints.

### UX Design Requirements

None

### FR Coverage Map

{{requirements_coverage_map}}

## Epic List

{{epics_list}}

<!-- Repeat for each epic in epics_list (N = 1, 2, 3...) -->

## Epic {{N}}: {{epic_title_N}}

{{epic_goal_N}}

<!-- Repeat for each story (M = 1, 2, 3...) within epic N -->

### Story {{N}}.{{M}}: {{story_title_N_M}}

As a {{user_type}},
I want {{capability}},
So that {{value_benefit}}.

**Acceptance Criteria:**

<!-- for each AC on this story -->

**Given** {{precondition}}
**When** {{action}}
**Then** {{expected_outcome}}
**And** {{additional_criteria}}

<!-- End story repeat -->
