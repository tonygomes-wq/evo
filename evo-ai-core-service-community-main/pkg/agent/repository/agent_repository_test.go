package repository

import (
	"context"
	"evo-ai-core-service/pkg/agent/model"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// setupTestDB creates a test database connection
func setupTestDB(t *testing.T) *gorm.DB {
	dsn := "host=localhost user=postgres password=postgres dbname=evo_core_test port=5432 sslmode=disable"
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	require.NoError(t, err, "Failed to connect to test database")

	// Auto migrate
	err = db.AutoMigrate(&model.Agent{})
	require.NoError(t, err, "Failed to migrate test database")

	return db
}

// cleanupTestDB cleans up test data
func cleanupTestDB(t *testing.T, db *gorm.DB) {
	db.Exec("DELETE FROM evo_core_agents WHERE name LIKE 'Test%'")
}

// createTestContext creates a context with account_id
func createTestContext(accountID uuid.UUID, role string) context.Context {
	ctx := context.Background()
	ctx = context.WithValue(ctx, "account_id", accountID)
	ctx = context.WithValue(ctx, "role", role)
	ctx = context.WithValue(ctx, "user_id", uuid.New())
	ctx = context.WithValue(ctx, "email", "test@example.com")
	return ctx
}

// TestTenantIsolation_Create tests that agents are created with correct account_id
func TestTenantIsolation_Create(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	repo := NewAgentRepository(db)

	accountA := uuid.New()
	ctx := createTestContext(accountA, "account_owner")

	agent := model.Agent{
		ID:          uuid.New(),
		Name:        "Test Agent A",
		Description: "Test Description",
		Type:        "chat",
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	// Create agent
	createdAgent, err := repo.Create(ctx, agent)
	require.NoError(t, err)
	require.NotNil(t, createdAgent)

	// Verify account_id was injected
	assert.NotNil(t, createdAgent.AccountID)
	assert.Equal(t, accountA, *createdAgent.AccountID)
}

// TestTenantIsolation_GetByID tests that users can only access their own account's agents
func TestTenantIsolation_GetByID(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	repo := NewAgentRepository(db)

	// Create two accounts
	accountA := uuid.New()
	accountB := uuid.New()

	// Create agent for Account A
	ctxA := createTestContext(accountA, "account_owner")
	agentA := model.Agent{
		ID:          uuid.New(),
		Name:        "Test Agent A",
		Description: "Agent for Account A",
		Type:        "chat",
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	createdAgentA, err := repo.Create(ctxA, agentA)
	require.NoError(t, err)

	// Create agent for Account B
	ctxB := createTestContext(accountB, "account_owner")
	agentB := model.Agent{
		ID:          uuid.New(),
		Name:        "Test Agent B",
		Description: "Agent for Account B",
		Type:        "chat",
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	createdAgentB, err := repo.Create(ctxB, agentB)
	require.NoError(t, err)

	// Test 1: Account A can access its own agent
	fetchedAgent, err := repo.GetByID(ctxA, createdAgentA.ID)
	require.NoError(t, err)
	assert.Equal(t, createdAgentA.ID, fetchedAgent.ID)

	// Test 2: Account A CANNOT access Account B's agent
	fetchedAgent, err = repo.GetByID(ctxA, createdAgentB.ID)
	assert.Error(t, err)
	assert.Nil(t, fetchedAgent)

	// Test 3: Account B can access its own agent
	fetchedAgent, err = repo.GetByID(ctxB, createdAgentB.ID)
	require.NoError(t, err)
	assert.Equal(t, createdAgentB.ID, fetchedAgent.ID)

	// Test 4: Account B CANNOT access Account A's agent
	fetchedAgent, err = repo.GetByID(ctxB, createdAgentA.ID)
	assert.Error(t, err)
	assert.Nil(t, fetchedAgent)
}

// TestTenantIsolation_List tests that List only returns agents from user's account
func TestTenantIsolation_List(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	repo := NewAgentRepository(db)

	accountA := uuid.New()
	accountB := uuid.New()

	// Create 3 agents for Account A
	ctxA := createTestContext(accountA, "account_owner")
	for i := 0; i < 3; i++ {
		agent := model.Agent{
			ID:          uuid.New(),
			Name:        "Test Agent A" + string(rune(i)),
			Description: "Agent for Account A",
			Type:        "chat",
			CreatedAt:   time.Now(),
			UpdatedAt:   time.Now(),
		}
		_, err := repo.Create(ctxA, agent)
		require.NoError(t, err)
	}

	// Create 2 agents for Account B
	ctxB := createTestContext(accountB, "account_owner")
	for i := 0; i < 2; i++ {
		agent := model.Agent{
			ID:          uuid.New(),
			Name:        "Test Agent B" + string(rune(i)),
			Description: "Agent for Account B",
			Type:        "chat",
			CreatedAt:   time.Now(),
			UpdatedAt:   time.Now(),
		}
		_, err := repo.Create(ctxB, agent)
		require.NoError(t, err)
	}

	// Test 1: Account A sees only its 3 agents
	agentsA, err := repo.List(ctxA, 1, 10)
	require.NoError(t, err)
	assert.GreaterOrEqual(t, len(agentsA), 3)
	for _, agent := range agentsA {
		if agent.Name[:11] == "Test Agent " {
			assert.Equal(t, accountA, *agent.AccountID)
		}
	}

	// Test 2: Account B sees only its 2 agents
	agentsB, err := repo.List(ctxB, 1, 10)
	require.NoError(t, err)
	assert.GreaterOrEqual(t, len(agentsB), 2)
	for _, agent := range agentsB {
		if agent.Name[:11] == "Test Agent " {
			assert.Equal(t, accountB, *agent.AccountID)
		}
	}
}

// TestTenantIsolation_Update tests that users can only update their own account's agents
func TestTenantIsolation_Update(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	repo := NewAgentRepository(db)

	accountA := uuid.New()
	accountB := uuid.New()

	// Create agent for Account A
	ctxA := createTestContext(accountA, "account_owner")
	agentA := model.Agent{
		ID:          uuid.New(),
		Name:        "Test Agent A",
		Description: "Original Description",
		Type:        "chat",
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	createdAgentA, err := repo.Create(ctxA, agentA)
	require.NoError(t, err)

	// Test 1: Account A can update its own agent
	ctxB := createTestContext(accountB, "account_owner")
	updatedAgent := &model.Agent{
		Description: "Updated Description",
	}
	result, err := repo.Update(ctxA, updatedAgent, createdAgentA.ID)
	require.NoError(t, err)
	assert.Equal(t, "Updated Description", result.Description)

	// Test 2: Account B CANNOT update Account A's agent
	updatedAgent = &model.Agent{
		Description: "Malicious Update",
	}
	result, err = repo.Update(ctxB, updatedAgent, createdAgentA.ID)
	assert.Error(t, err)
	assert.Nil(t, result)

	// Verify agent was not updated
	fetchedAgent, err := repo.GetByID(ctxA, createdAgentA.ID)
	require.NoError(t, err)
	assert.Equal(t, "Updated Description", fetchedAgent.Description)
}

// TestTenantIsolation_Delete tests that users can only delete their own account's agents
func TestTenantIsolation_Delete(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	repo := NewAgentRepository(db)

	accountA := uuid.New()
	accountB := uuid.New()

	// Create agent for Account A
	ctxA := createTestContext(accountA, "account_owner")
	agentA := model.Agent{
		ID:          uuid.New(),
		Name:        "Test Agent A",
		Description: "To be deleted",
		Type:        "chat",
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	createdAgentA, err := repo.Create(ctxA, agentA)
	require.NoError(t, err)

	// Test 1: Account B CANNOT delete Account A's agent
	ctxB := createTestContext(accountB, "account_owner")
	deleted, err := repo.Delete(ctxB, createdAgentA.ID)
	assert.NoError(t, err) // GORM doesn't error on 0 rows affected
	assert.True(t, deleted)

	// Verify agent still exists
	fetchedAgent, err := repo.GetByID(ctxA, createdAgentA.ID)
	require.NoError(t, err)
	assert.NotNil(t, fetchedAgent)

	// Test 2: Account A CAN delete its own agent
	deleted, err = repo.Delete(ctxA, createdAgentA.ID)
	require.NoError(t, err)
	assert.True(t, deleted)

	// Verify agent is deleted
	fetchedAgent, err = repo.GetByID(ctxA, createdAgentA.ID)
	assert.Error(t, err)
	assert.Nil(t, fetchedAgent)
}

// TestSuperAdminBypass tests that super_admin can access all accounts
func TestSuperAdminBypass(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	repo := NewAgentRepository(db)

	accountA := uuid.New()
	accountB := uuid.New()

	// Create agents for both accounts
	ctxA := createTestContext(accountA, "account_owner")
	agentA := model.Agent{
		ID:          uuid.New(),
		Name:        "Test Agent A",
		Description: "Agent for Account A",
		Type:        "chat",
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	createdAgentA, err := repo.Create(ctxA, agentA)
	require.NoError(t, err)

	ctxB := createTestContext(accountB, "account_owner")
	agentB := model.Agent{
		ID:          uuid.New(),
		Name:        "Test Agent B",
		Description: "Agent for Account B",
		Type:        "chat",
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	createdAgentB, err := repo.Create(ctxB, agentB)
	require.NoError(t, err)

	// Test 1: Super Admin without account_id sees ALL agents
	ctxSuperAdmin := context.Background()
	ctxSuperAdmin = context.WithValue(ctxSuperAdmin, "role", "super_admin")
	ctxSuperAdmin = context.WithValue(ctxSuperAdmin, "user_id", uuid.New())
	ctxSuperAdmin = context.WithValue(ctxSuperAdmin, "email", "admin@example.com")

	allAgents, err := repo.List(ctxSuperAdmin, 1, 100)
	require.NoError(t, err)
	assert.GreaterOrEqual(t, len(allAgents), 2)

	// Test 2: Super Admin WITH account_id sees only that account
	ctxSuperAdminFiltered := context.WithValue(ctxSuperAdmin, "account_id", accountA)
	filteredAgents, err := repo.List(ctxSuperAdminFiltered, 1, 100)
	require.NoError(t, err)
	for _, agent := range filteredAgents {
		if agent.Name[:11] == "Test Agent " {
			assert.Equal(t, accountA, *agent.AccountID)
		}
	}

	// Test 3: Super Admin can access any agent by ID
	fetchedAgentA, err := repo.GetByID(ctxSuperAdmin, createdAgentA.ID)
	require.NoError(t, err)
	assert.Equal(t, createdAgentA.ID, fetchedAgentA.ID)

	fetchedAgentB, err := repo.GetByID(ctxSuperAdmin, createdAgentB.ID)
	require.NoError(t, err)
	assert.Equal(t, createdAgentB.ID, fetchedAgentB.ID)
}

// TestCount tests that Count respects tenant isolation
func TestTenantIsolation_Count(t *testing.T) {
	db := setupTestDB(t)
	defer cleanupTestDB(t, db)

	repo := NewAgentRepository(db)

	accountA := uuid.New()
	accountB := uuid.New()

	// Create 5 agents for Account A
	ctxA := createTestContext(accountA, "account_owner")
	for i := 0; i < 5; i++ {
		agent := model.Agent{
			ID:          uuid.New(),
			Name:        "Test Agent A" + string(rune(i)),
			Description: "Agent for Account A",
			Type:        "chat",
			CreatedAt:   time.Now(),
			UpdatedAt:   time.Now(),
		}
		_, err := repo.Create(ctxA, agent)
		require.NoError(t, err)
	}

	// Create 3 agents for Account B
	ctxB := createTestContext(accountB, "account_owner")
	for i := 0; i < 3; i++ {
		agent := model.Agent{
			ID:          uuid.New(),
			Name:        "Test Agent B" + string(rune(i)),
			Description: "Agent for Account B",
			Type:        "chat",
			CreatedAt:   time.Now(),
			UpdatedAt:   time.Now(),
		}
		_, err := repo.Create(ctxB, agent)
		require.NoError(t, err)
	}

	// Test 1: Account A count
	countA, err := repo.Count(ctxA)
	require.NoError(t, err)
	assert.GreaterOrEqual(t, countA, int64(5))

	// Test 2: Account B count
	countB, err := repo.Count(ctxB)
	require.NoError(t, err)
	assert.GreaterOrEqual(t, countB, int64(3))

	// Test 3: Super Admin count (all accounts)
	ctxSuperAdmin := context.Background()
	ctxSuperAdmin = context.WithValue(ctxSuperAdmin, "role", "super_admin")
	countAll, err := repo.Count(ctxSuperAdmin)
	require.NoError(t, err)
	assert.GreaterOrEqual(t, countAll, int64(8))
}
