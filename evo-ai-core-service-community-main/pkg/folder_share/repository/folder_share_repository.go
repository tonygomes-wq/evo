package repository

import (
	"context"
	"evo-ai-core-service/internal/utils/contextutils"
	"evo-ai-core-service/pkg/folder_share/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type FolderShareRepository interface {
	GetByID(ctx context.Context, id uuid.UUID) (*model.FolderShare, error)
	GetByFolderIDAndSharedWithEmail(ctx context.Context, folderID uuid.UUID, sharedWithEmail string) (*model.FolderShare, error)
	Create(ctx context.Context, folderShare model.FolderShare) (*model.FolderShare, error)
	Update(ctx context.Context, id uuid.UUID, folderShare *model.FolderShare) (*model.FolderShare, error)
	Delete(ctx context.Context, id uuid.UUID) (bool, error)
	GetSharedFolder(ctx context.Context, folderId uuid.UUID, page int, pageSize int) ([]model.FolderShare, error)
	CountSharedFolder(ctx context.Context, folderId uuid.UUID) (int64, error)
	CountSharedFoldersWithEmail(ctx context.Context, email string) (int64, error)
	GetSharedFoldersWithEmail(ctx context.Context, sharedWithEmail string, page int, pageSize int) ([]model.FolderShare, error)
	ListSharedFoldersByEmail(ctx context.Context, userEmail string, page int, pageSize int) ([]*model.FolderShare, error)
}

type folderShareRepository struct {
	db *gorm.DB
}

func NewFolderShareRepository(db *gorm.DB) FolderShareRepository {
	return &folderShareRepository{db: db}
}

func (r *folderShareRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.FolderShare, error) {
	var folderShare model.FolderShare
	
	query := r.db.WithContext(ctx).Where("id = ?", id)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.First(&folderShare).Error; err != nil {
		return nil, err
	}

	return &folderShare, nil
}

func (r *folderShareRepository) GetByFolderIDAndSharedWithEmail(ctx context.Context, folderID uuid.UUID, sharedWithEmail string) (*model.FolderShare, error) {
	var folderShare model.FolderShare
	
	query := r.db.WithContext(ctx).Where("folder_id = ? AND shared_with_email = ? AND is_active = ?", folderID, sharedWithEmail, true)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.First(&folderShare).Error; err != nil {
		return nil, err
	}

	return &folderShare, nil
}

func (r *folderShareRepository) Create(ctx context.Context, folderShare model.FolderShare) (*model.FolderShare, error) {
	// Inject account_id from context
	accountID := contextutils.GetAccountIDFromContext(ctx)
	if accountID != uuid.Nil {
		folderShare.AccountID = &accountID
	}

	if err := r.db.WithContext(ctx).Create(&folderShare).Error; err != nil {
		return nil, err
	}

	return &folderShare, nil
}

func (r *folderShareRepository) Update(ctx context.Context, id uuid.UUID, folderShare *model.FolderShare) (*model.FolderShare, error) {
	query := r.db.WithContext(ctx).Model(&model.FolderShare{}).Where("id = ?", id)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.Updates(folderShare).First(&folderShare).Error; err != nil {
		return nil, err
	}

	return folderShare, nil
}

func (r *folderShareRepository) Delete(ctx context.Context, id uuid.UUID) (bool, error) {
	query := r.db.WithContext(ctx).Model(&model.FolderShare{}).Where("id = ?", id)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.Update("is_active", false).Error; err != nil {
		return false, err
	}

	return true, nil
}

func (r *folderShareRepository) GetSharedFolder(ctx context.Context, folderId uuid.UUID, page int, pageSize int) ([]model.FolderShare, error) {
	var folderShares []model.FolderShare
	query := r.db.WithContext(ctx).Where("folder_id = ? AND is_active = ?", folderId, true)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.Offset((page - 1) * pageSize).Limit(pageSize).Find(&folderShares).Error; err != nil {
		return nil, err
	}

	return folderShares, nil
}

func (r *folderShareRepository) GetSharedFoldersWithEmail(ctx context.Context, sharedWithEmail string, page int, pageSize int) ([]model.FolderShare, error) {
	var folderShares []model.FolderShare
	query := r.db.WithContext(ctx).Where("shared_with_email = ? AND is_active = ?", sharedWithEmail, true)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.Offset((page - 1) * pageSize).Limit(pageSize).Find(&folderShares).Error; err != nil {
		return nil, err
	}

	return folderShares, nil
}

func (r *folderShareRepository) ListSharedFoldersByEmail(ctx context.Context, userEmail string, page int, pageSize int) ([]*model.FolderShare, error) {
	var folderShares []*model.FolderShare

	query := r.db.WithContext(ctx).
		Preload("Folder").
		Where("folder_shares.shared_with_email = ? AND folder_shares.is_active = ?", userEmail, true)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("folder_shares.account_id = ?", accountID)
		}
	}

	if err := query.Offset((page - 1) * pageSize).
		Limit(pageSize).
		Find(&folderShares).Error; err != nil {
		return nil, err
	}

	return folderShares, nil
}

func (r *folderShareRepository) CountSharedFolder(ctx context.Context, folderId uuid.UUID) (int64, error) {
	var count int64
	query := r.db.WithContext(ctx).Model(&model.FolderShare{}).Where("folder_id = ?", folderId)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.Count(&count).Error; err != nil {
		return 0, err
	}
	return count, nil
}

func (r *folderShareRepository) CountSharedFoldersWithEmail(ctx context.Context, email string) (int64, error) {
	var count int64
	query := r.db.WithContext(ctx).Model(&model.FolderShare{}).Where("shared_with_email = ?", email)

	// Filter by account_id (except for Super Admin without specific account)
	if contextutils.ShouldFilterByAccount(ctx) {
		accountID := contextutils.GetAccountIDFromContext(ctx)
		if accountID != uuid.Nil {
			query = query.Where("account_id = ?", accountID)
		}
	}

	if err := query.Count(&count).Error; err != nil {
		return 0, err
	}
	return count, nil
}
