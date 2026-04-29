package repository

import (
	"context"
	"evo-ai-core-service/internal/utils/contextutils"
	"evo-ai-core-service/pkg/custom_tool/model"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"gorm.io/gorm"
)

type CustomToolRepository interface {
	Create(ctx context.Context, customTool model.CustomTool) (*model.CustomTool, error)
	GetByID(ctx context.Context, id uuid.UUID) (*model.CustomTool, error)
	List(ctx context.Context, request model.CustomToolListRequest) ([]*model.CustomTool, error)
	Count(ctx context.Context, request model.CustomToolListRequest) (int64, error)
	Update(ctx context.Context, customTool *model.CustomTool, id uuid.UUID) (*model.CustomTool, error)
	Delete(ctx context.Context, id uuid.UUID) (bool, error)
}

type customToolRepository struct {
	db *gorm.DB
}

func NewCustomToolRepository(db *gorm.DB) CustomToolRepository {
	return &customToolRepository{db: db}
}

func (r *customToolRepository) Create(ctx context.Context, customTool model.CustomTool) (*model.CustomTool, error) {
	// Inject account_id from context
	accountID := contextutils.GetAccountIDFromContext(ctx)
	if accountID != uuid.Nil {
		customTool.AccountID = &accountID
	}

	if err := r.db.WithContext(ctx).Create(&customTool).Error; err != nil {
		return nil, err
	}

	return &customTool, nil
}

func (r *customToolRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.CustomTool, error) {
	var customTool model.CustomTool

	query := r.db.WithContext(ctx).Where("id = ?", id)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.First(&customTool).Error; err != nil {
		return nil, err
	}

	return &customTool, nil
}

func (r *customToolRepository) List(ctx context.Context, request model.CustomToolListRequest) ([]*model.CustomTool, error) {
	var customTool []*model.CustomTool

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

	if err := query.Offset((request.Page - 1) * request.PageSize).Limit(request.PageSize).Find(&customTool).Error; err != nil {
		return []*model.CustomTool{}, err
	}

	return customTool, nil
}

func (r *customToolRepository) Count(ctx context.Context, request model.CustomToolListRequest) (int64, error) {
	var count int64

	query := r.db.WithContext(ctx).Model(&model.CustomTool{})

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

func (r *customToolRepository) Update(ctx context.Context, customTool *model.CustomTool, id uuid.UUID) (*model.CustomTool, error) {
	customTool.UpdatedAt = time.Now()
	
	query := r.db.WithContext(ctx).Where("id = ?", id)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.Updates(customTool).First(&customTool).Error; err != nil {
		return nil, err
	}

	return customTool, nil
}

func (r *customToolRepository) Delete(ctx context.Context, id uuid.UUID) (bool, error) {
	query := r.db.WithContext(ctx).Model(&model.CustomTool{}).Where("id = ?", id)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.Delete(&model.CustomTool{}).Error; err != nil {
		return false, err
	}

	return true, nil
}
