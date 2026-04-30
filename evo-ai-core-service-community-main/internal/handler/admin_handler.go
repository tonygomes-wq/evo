package handler

import (
	"evo-ai-core-service/internal/utils/contextutils"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// AdminHandler handles admin-related requests
type AdminHandler struct {
	db *gorm.DB
}

// NewAdminHandler creates a new admin handler
func NewAdminHandler(db *gorm.DB) *AdminHandler {
	return &AdminHandler{db: db}
}

// Account represents an account in the system
type Account struct {
	ID        uuid.UUID `json:"id" gorm:"type:uuid;primary_key"`
	Name      string    `json:"name" gorm:"type:varchar(255);not null"`
	Status    string    `json:"status" gorm:"type:varchar(50);not null;default:'active'"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// AccountStats represents statistics for an account
type AccountStats struct {
	AccountID          uuid.UUID `json:"account_id"`
	AccountName        string    `json:"account_name"`
	TotalAgents        int64     `json:"total_agents"`
	TotalCustomTools   int64     `json:"total_custom_tools"`
	TotalAPIKeys       int64     `json:"total_api_keys"`
	TotalFolders       int64     `json:"total_folders"`
	TotalFolderShares  int64     `json:"total_folder_shares"`
	TotalMCPServers    int64     `json:"total_mcp_servers"`
	TotalIntegrations  int64     `json:"total_integrations"`
	CreatedAt          time.Time `json:"created_at"`
}

// CreateAccountRequest represents a request to create an account
type CreateAccountRequest struct {
	Name   string `json:"name" binding:"required"`
	Status string `json:"status"`
}

// UpdateAccountStatusRequest represents a request to update account status
type UpdateAccountStatusRequest struct {
	Status string `json:"status" binding:"required,oneof=active inactive suspended"`
}

// ========================================
// Super Admin Endpoints
// ========================================

// ListAccounts lists all accounts (Super Admin only)
// GET /api/v1/admin/accounts
func (h *AdminHandler) ListAccounts(c *gin.Context) {
	var accounts []Account

	if err := h.db.Order("created_at DESC").Find(&accounts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch accounts"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"accounts": accounts,
		"total":    len(accounts),
	})
}

// CreateAccount creates a new account (Super Admin only)
// POST /api/v1/admin/accounts
func (h *AdminHandler) CreateAccount(c *gin.Context) {
	var req CreateAccountRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Default status to active if not provided
	if req.Status == "" {
		req.Status = "active"
	}

	account := Account{
		ID:        uuid.New(),
		Name:      req.Name,
		Status:    req.Status,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := h.db.Create(&account).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create account"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Account created successfully",
		"account": account,
	})
}

// GetAccountStats gets statistics for a specific account (Super Admin only)
// GET /api/v1/admin/accounts/:id/stats
func (h *AdminHandler) GetAccountStats(c *gin.Context) {
	accountID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid account ID"})
		return
	}

	// Get account info
	var account Account
	if err := h.db.Where("id = ?", accountID).First(&account).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Account not found"})
		return
	}

	// Get statistics
	stats := AccountStats{
		AccountID:   accountID,
		AccountName: account.Name,
		CreatedAt:   account.CreatedAt,
	}

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_agents").
		Where("account_id = ?", accountID).
		Count(&stats.TotalAgents)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_custom_tools").
		Where("account_id = ?", accountID).
		Count(&stats.TotalCustomTools)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_api_keys").
		Where("account_id = ?", accountID).
		Count(&stats.TotalAPIKeys)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_folders").
		Where("account_id = ?", accountID).
		Count(&stats.TotalFolders)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_folder_shares").
		Where("account_id = ?", accountID).
		Count(&stats.TotalFolderShares)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_custom_mcp_servers").
		Where("account_id = ?", accountID).
		Count(&stats.TotalMCPServers)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_agent_integrations").
		Where("account_id = ?", accountID).
		Count(&stats.TotalIntegrations)

	c.JSON(http.StatusOK, stats)
}

// UpdateAccountStatus updates the status of an account (Super Admin only)
// PATCH /api/v1/admin/accounts/:id/status
func (h *AdminHandler) UpdateAccountStatus(c *gin.Context) {
	accountID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid account ID"})
		return
	}

	var req UpdateAccountStatusRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update account status
	result := h.db.Model(&Account{}).
		Where("id = ?", accountID).
		Updates(map[string]interface{}{
			"status":     req.Status,
			"updated_at": time.Now(),
		})

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update account status"})
		return
	}

	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Account not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Account status updated successfully",
		"status":  req.Status,
	})
}

// GetAccountResourcesCount gets resource counts before deletion (Super Admin only)
// GET /api/v1/admin/accounts/:id/resources-count
func (h *AdminHandler) GetAccountResourcesCount(c *gin.Context) {
	accountID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid account ID"})
		return
	}

	// Get resource counts
	var counts struct {
		Agents        int64 `json:"agents"`
		CustomTools   int64 `json:"custom_tools"`
		APIKeys       int64 `json:"api_keys"`
		Folders       int64 `json:"folders"`
		FolderShares  int64 `json:"folder_shares"`
		MCPServers    int64 `json:"mcp_servers"`
		Integrations  int64 `json:"integrations"`
	}

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_agents").
		Where("account_id = ?", accountID).
		Count(&counts.Agents)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_custom_tools").
		Where("account_id = ?", accountID).
		Count(&counts.CustomTools)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_api_keys").
		Where("account_id = ?", accountID).
		Count(&counts.APIKeys)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_folders").
		Where("account_id = ?", accountID).
		Count(&counts.Folders)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_folder_shares").
		Where("account_id = ?", accountID).
		Count(&counts.FolderShares)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_custom_mcp_servers").
		Where("account_id = ?", accountID).
		Count(&counts.MCPServers)

	h.db.Model(&struct{ AccountID uuid.UUID }{}).
		Table("evo_core_agent_integrations").
		Where("account_id = ?", accountID).
		Count(&counts.Integrations)

	total := counts.Agents + counts.CustomTools + counts.APIKeys + 
		counts.Folders + counts.FolderShares + counts.MCPServers + counts.Integrations

	c.JSON(http.StatusOK, gin.H{
		"account_id":     accountID,
		"resource_count": counts,
		"total_resources": total,
		"warning": "Deleting this account will permanently delete all associated resources",
	})
}

// ========================================
// Account Owner Endpoints
// ========================================

// GetAccountInfo gets information about the current account
// GET /api/v1/account/info
func (h *AdminHandler) GetAccountInfo(c *gin.Context) {
	ctx := c.Request.Context()
	accountID := contextutils.GetAccountIDFromContext(ctx)

	if accountID == uuid.Nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No account context"})
		return
	}

	var account Account
	if err := h.db.Where("id = ?", accountID).First(&account).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Account not found"})
		return
	}

	c.JSON(http.StatusOK, account)
}

// GetMyAccountStats gets statistics for the current user's account
// GET /api/v1/account/stats
func (h *AdminHandler) GetMyAccountStats(c *gin.Context) {
	ctx := c.Request.Context()
	accountID := contextutils.GetAccountIDFromContext(ctx)

	if accountID == uuid.Nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No account context"})
		return
	}

	// Reuse the GetAccountStats logic
	c.Params = append(c.Params, gin.Param{Key: "id", Value: accountID.String()})
	h.GetAccountStats(c)
}

// ========================================
// Account User Endpoints
// ========================================

// GetMyPermissions gets the current user's permissions
// GET /api/v1/account/my-permissions
func (h *AdminHandler) GetMyPermissions(c *gin.Context) {
	ctx := c.Request.Context()

	role := contextutils.GetRoleFromContext(ctx)
	permission := contextutils.GetPermissionFromContext(ctx)
	accountID := contextutils.GetAccountIDFromContext(ctx)
	userID, _ := contextutils.GetUserIDFromContext(ctx)
	email, _ := contextutils.GetUserEmailFromContext(ctx)

	c.JSON(http.StatusOK, gin.H{
		"user_id":    userID,
		"email":      email,
		"account_id": accountID,
		"role":       role,
		"permission": permission,
		"capabilities": gin.H{
			"can_read":            role != "",
			"can_create":          role == "super_admin" || role == "account_owner" || permission == "editor" || permission == "account_admin",
			"can_update":          role == "super_admin" || role == "account_owner" || permission == "editor" || permission == "account_admin",
			"can_delete":          role == "super_admin" || role == "account_owner" || permission == "account_admin",
			"can_manage_users":    role == "super_admin" || role == "account_owner",
			"can_manage_accounts": role == "super_admin",
		},
	})
}
