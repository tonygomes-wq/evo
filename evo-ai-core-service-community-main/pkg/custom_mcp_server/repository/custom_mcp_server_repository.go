package repository

import (
	"context"
	"evo-ai-core-service/internal/utils/contextutils"
	"evo-ai-core-service/pkg/custom_mcp_server/model"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"gorm.io/gorm"
)

type CustomMcpServerRepository interface {
	Create(ctx context.Context, customMcpServer model.CustomMcpServer) (*model.CustomMcpServer, error)
	GetByID(ctx context.Context, id uuid.UUID) (*model.CustomMcpServer, error)
	List(ctx context.Context, request model.CustomMcpServerListRequest) ([]*model.CustomMcpServer, error)
	Count(ctx context.Context, request model.CustomMcpServerListRequest) (int64, error)
	Update(ctx context.Context, customMcpServer *model.CustomMcpServer, id uuid.UUID) (*model.CustomMcpServer, error)
	Delete(ctx context.Context, id uuid.UUID) (bool, error)
	GetByAgentConfig(ctx context.Context, serverIDs []uuid.UUID) ([]*model.CustomMcpServer, error)
}

type customMcpServerRepository struct {
	db *gorm.DB
}

func NewCustomMcpServerRepository(db *gorm.DB) CustomMcpServerRepository {
	return &customMcpServerRepository{db: db}
}

func (r *customMcpServerRepository) Create(ctx context.Context, customMcpServer model.CustomMcpServer) (*model.CustomMcpServer, error) {
	// Inject account_id from context
	accountID := contextutils.GetAccountIDFromContext(ctx)
	if accountID != uuid.Nil {
		customMcpServer.AccountID = &accountID
	}

	if err := r.db.WithContext(ctx).Create(&customMcpServer).Error; err != nil {
		return nil, err
	}

	return &customMcpServer, nil
}

func (r *customMcpServerRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.CustomMcpServer, error) {
	var customMcpServer model.CustomMcpServer

	query := r.db.WithContext(ctx).Where("id = ?", id)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.First(&customMcpServer).Error; err != nil {
		return nil, err
	}

	return &customMcpServer, nil
}

func (r *customMcpServerRepository) List(ctx context.Context, request model.CustomMcpServerListRequest) ([]*model.CustomMcpServer, error) {
	var customMcpServer []*model.CustomMcpServer

	query := r.db.WithContext(ctx)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if request.Search != "" {
		query = query.Where("name ILIKE ?", "%"+request.Search+"%")
	}

	if request.Tags != "" {
		query = query.Where("tags && ?", pq.Array(strings.Split(request.Tags, ",")))
	}

	if err := query.Offset((request.Page - 1) * request.PageSize).Limit(request.PageSize).Find(&customMcpServer).Error; err != nil {
		return []*model.CustomMcpServer{}, err
	}

	return customMcpServer, nil
}

func (r *customMcpServerRepository) Count(ctx context.Context, request model.CustomMcpServerListRequest) (int64, error) {
	var count int64

	query := r.db.WithContext(ctx).Model(&model.CustomMcpServer{})

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if request.Search != "" {
		query = query.Where("name ILIKE ?", "%"+request.Search+"%")
	}

	if request.Tags != "" {
		query = query.Where("tags && ?", pq.Array(strings.Split(request.Tags, ",")))
	}

	if err := query.Count(&count).Error; err != nil {
		return 0, err
	}

	return count, nil
}

func (r *customMcpServerRepository) Update(ctx context.Context, customMcpServer *model.CustomMcpServer, id uuid.UUID) (*model.CustomMcpServer, error) {
	customMcpServer.UpdatedAt = time.Now()
	
	query := r.db.WithContext(ctx).Where("id = ?", id)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.Updates(customMcpServer).First(&customMcpServer).Error; err != nil {
		return nil, err
	}

	return customMcpServer, nil
}

func (r *customMcpServerRepository) Delete(ctx context.Context, id uuid.UUID) (bool, error) {
	query := r.db.WithContext(ctx).Model(&model.CustomMcpServer{}).Where("id = ?", id)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.Delete(&model.CustomMcpServer{}).Error; err != nil {
		return false, err
	}

	return true, nil
}

func (r *customMcpServerRepository) GetByAgentConfig(ctx context.Context, serverIDs []uuid.UUID) ([]*model.CustomMcpServer, error) {
	var customMcpServer []*model.CustomMcpServer

	query := r.db.WithContext(ctx).Where("id IN (?)", serverIDs)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.Find(&customMcpServer).Error; err != nil {
		return nil, err
	}

	return customMcpServer, nil
}
