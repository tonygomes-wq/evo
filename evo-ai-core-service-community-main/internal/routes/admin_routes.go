package routes

import (
	"evo-ai-core-service/internal/handler"
	"evo-ai-core-service/internal/middleware"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// SetupAdminRoutes sets up admin-related routes
func SetupAdminRoutes(router *gin.RouterGroup, db *gorm.DB, authMiddleware *middleware.AuthorizationMiddleware) {
	adminHandler := handler.NewAdminHandler(db)

	// ========================================
	// Super Admin Routes
	// ========================================
	superAdminGroup := router.Group("/admin")
	superAdminGroup.Use(authMiddleware.RequireSuperAdmin())
	{
		// Account Management
		superAdminGroup.GET("/accounts", adminHandler.ListAccounts)
		superAdminGroup.POST("/accounts", adminHandler.CreateAccount)
		superAdminGroup.GET("/accounts/:id/stats", adminHandler.GetAccountStats)
		superAdminGroup.PATCH("/accounts/:id/status", adminHandler.UpdateAccountStatus)
		superAdminGroup.GET("/accounts/:id/resources-count", adminHandler.GetAccountResourcesCount)

		// Future: Audit logs, performance monitoring, etc.
		// superAdminGroup.GET("/audit-logs", adminHandler.GetAuditLogs)
		// superAdminGroup.GET("/performance/slow-queries", adminHandler.GetSlowQueries)
	}

	// ========================================
	// Account Owner Routes
	// ========================================
	accountGroup := router.Group("/account")
	accountGroup.Use(authMiddleware.RequireViewer()) // All authenticated users
	{
		// Account Information (all users can view)
		accountGroup.GET("/info", adminHandler.GetAccountInfo)
		accountGroup.GET("/stats", adminHandler.GetMyAccountStats)

		// User Permissions (all users can view their own)
		accountGroup.GET("/my-permissions", adminHandler.GetMyPermissions)

		// User Management (Account Owner only)
		// Future implementation:
		// accountOwnerGroup := accountGroup.Group("")
		// accountOwnerGroup.Use(authMiddleware.RequireAccountOwner())
		// {
		//     accountOwnerGroup.GET("/users", adminHandler.ListAccountUsers)
		//     accountOwnerGroup.POST("/users", adminHandler.InviteUser)
		//     accountOwnerGroup.PATCH("/users/:id/role", adminHandler.UpdateUserRole)
		//     accountOwnerGroup.DELETE("/users/:id", adminHandler.RemoveUser)
		// }
	}
}
