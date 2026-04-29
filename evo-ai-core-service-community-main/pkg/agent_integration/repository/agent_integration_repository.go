package repository

import (
	"context"
	"evo-ai-core-service/internal/utils/contextutils"
	"evo-ai-core-service/pkg/agent_integration/model"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type AgentIntegrationRepository interface {
	Upsert(ctx context.Context, integration model.AgentIntegration) (*model.AgentIntegration, error)
	GetByAgentAndProvider(ctx context.Context, agentID uuid.UUID, provider string) (*model.AgentIntegration, error)
	ListByAgent(ctx context.Context, agentID uuid.UUID) ([]*model.AgentIntegration, error)
	Delete(ctx context.Context, agentID uuid.UUID, provider string) error
}

type agentIntegrationRepository struct {
	db *gorm.DB
}

func NewAgentIntegrationRepository(db *gorm.DB) AgentIntegrationRepository {
	return &agentIntegrationRepository{db: db}
}

func (r *agentIntegrationRepository) Upsert(ctx context.Context, integration model.AgentIntegration) (*model.AgentIntegration, error) {
	integration.UpdatedAt = time.Now()

	// Inject account_id from context
	accountID := contextutils.GetAccountIDFromContext(ctx)
	if accountID != uuid.Nil {
		integration.AccountID = &accountID
	}

	// Use GORM's upsert functionality
	err := r.db.WithContext(ctx).Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "agent_id"}, {Name: "provider"}},
		DoUpdates: clause.AssignmentColumns([]string{"config", "updated_at"}),
	}).Create(&integration).Error

	if err != nil {
		return nil, err
	}

	return &integration, nil
}

func (r *agentIntegrationRepository) GetByAgentAndProvider(ctx context.Context, agentID uuid.UUID, provider string) (*model.AgentIntegration, error) {
	var integration model.AgentIntegration

	query := r.db.WithContext(ctx).
		Where("agent_id = ? AND provider = ?", agentID, provider)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	err := query.First(&integration).Error

	if err != nil {
		return nil, err
	}

	return &integration, nil
}

func (r *agentIntegrationRepository) ListByAgent(ctx context.Context, agentID uuid.UUID) ([]*model.AgentIntegration, error) {
	var integrations []*model.AgentIntegration

	query := r.db.WithContext(ctx).
		Where("agent_id = ?", agentID)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	err := query.Find(&integrations).Error

	if err != nil {
		return nil, err
	}

	return integrations, nil
}

func (r *agentIntegrationRepository) Delete(ctx context.Context, agentID uuid.UUID, provider string) error {
	query := r.db.WithContext(ctx).
		Where("agent_id = ? AND provider = ?", agentID, provider)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	return query.Delete(&model.AgentIntegration{}).Error
}
