package middleware

import (
	"evo-ai-core-service/internal/utils/contextutils"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// Permission levels for Account Users
const (
	PermissionViewer       = "viewer"        // Read-only access
	PermissionEditor       = "editor"        // Read and write access
	PermissionAccountAdmin = "account_admin" // Full access except user management
)

// Role levels
const (
	RoleSuperAdmin   = "super_admin"   // Global admin
	RoleAccountOwner = "account_owner" // Account owner
	RoleAccountUser  = "account_user"  // Regular account user
)

// AuthorizationMiddleware provides role-based access control
type AuthorizationMiddleware struct{}

// NewAuthorizationMiddleware creates a new authorization middleware
func NewAuthorizationMiddleware() *AuthorizationMiddleware {
	return &AuthorizationMiddleware{}
}

// RequireSuperAdmin ensures the user has super_admin role
func (m *AuthorizationMiddleware) RequireSuperAdmin() gin.HandlerFunc {
	return func(c *gin.Context) {
		if !contextutils.IsSuperAdmin(c.Request.Context()) {
			c.JSON(http.StatusForbidden, gin.H{
				"error": "Access denied: super_admin role required",
			})
			c.Abort()
			return
		}
		c.Next()
	}
}

// RequireAccountOwner ensures the user is account_owner or super_admin
func (m *AuthorizationMiddleware) RequireAccountOwner() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx := c.Request.Context()
		role := contextutils.GetRoleFromContext(ctx)

		if role != RoleSuperAdmin && role != RoleAccountOwner {
			c.JSON(http.StatusForbidden, gin.H{
				"error": "Access denied: account_owner role required",
			})
			c.Abort()
			return
		}
		c.Next()
	}
}

// RequireAccountAdmin ensures the user has account_admin permission or higher
func (m *AuthorizationMiddleware) RequireAccountAdmin() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx := c.Request.Context()
		role := contextutils.GetRoleFromContext(ctx)
		permission := contextutils.GetPermissionFromContext(ctx)

		// Super Admin and Account Owner always have access
		if role == RoleSuperAdmin || role == RoleAccountOwner {
			c.Next()
			return
		}

		// Account User must have account_admin permission
		if role == RoleAccountUser && permission == PermissionAccountAdmin {
			c.Next()
			return
		}

		c.JSON(http.StatusForbidden, gin.H{
			"error": "Access denied: account_admin permission required",
		})
		c.Abort()
	}
}

// RequireEditor ensures the user has editor permission or higher
func (m *AuthorizationMiddleware) RequireEditor() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx := c.Request.Context()
		role := contextutils.GetRoleFromContext(ctx)
		permission := contextutils.GetPermissionFromContext(ctx)

		// Super Admin and Account Owner always have access
		if role == RoleSuperAdmin || role == RoleAccountOwner {
			c.Next()
			return
		}

		// Account User must have editor or account_admin permission
		if role == RoleAccountUser {
			if permission == PermissionEditor || permission == PermissionAccountAdmin {
				c.Next()
				return
			}
		}

		c.JSON(http.StatusForbidden, gin.H{
			"error": "Access denied: editor permission required",
		})
		c.Abort()
	}
}

// RequireViewer ensures the user has at least viewer permission (any authenticated user)
func (m *AuthorizationMiddleware) RequireViewer() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx := c.Request.Context()
		role := contextutils.GetRoleFromContext(ctx)

		// All authenticated users with a role can view
		if role == "" {
			c.JSON(http.StatusForbidden, gin.H{
				"error": "Access denied: authentication required",
			})
			c.Abort()
			return
		}

		c.Next()
	}
}

// RequireResourceOwnership ensures the user owns the resource or is super_admin
func (m *AuthorizationMiddleware) RequireResourceOwnership(resourceAccountID *uuid.UUID) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx := c.Request.Context()

		// Validate access
		if err := contextutils.ValidateAccountAccess(ctx, resourceAccountID); err != nil {
			c.JSON(http.StatusForbidden, gin.H{
				"error": "Access denied: you don't have permission to access this resource",
			})
			c.Abort()
			return
		}

		c.Next()
	}
}

// GetAuthorizationMiddleware returns the authorization middleware instance
func (m *AuthorizationMiddleware) GetAuthorizationMiddleware() gin.HandlerFunc {
	// This is a placeholder for general authorization checks
	// Specific route protection should use the specific middleware methods above
	return func(c *gin.Context) {
		c.Next()
	}
}

// PermissionMatrix defines what each role/permission can do
type PermissionMatrix struct {
	CanRead   bool
	CanCreate bool
	CanUpdate bool
	CanDelete bool
	CanManageUsers bool
	CanManageAccounts bool
}

// GetPermissionMatrix returns the permission matrix for a role/permission combination
func GetPermissionMatrix(role string, permission string) PermissionMatrix {
	switch role {
	case RoleSuperAdmin:
		return PermissionMatrix{
			CanRead:           true,
			CanCreate:         true,
			CanUpdate:         true,
			CanDelete:         true,
			CanManageUsers:    true,
			CanManageAccounts: true,
		}
	case RoleAccountOwner:
		return PermissionMatrix{
			CanRead:           true,
			CanCreate:         true,
			CanUpdate:         true,
			CanDelete:         true,
			CanManageUsers:    true,
			CanManageAccounts: false,
		}
	case RoleAccountUser:
		switch permission {
		case PermissionAccountAdmin:
			return PermissionMatrix{
				CanRead:           true,
				CanCreate:         true,
				CanUpdate:         true,
				CanDelete:         true,
				CanManageUsers:    false,
				CanManageAccounts: false,
			}
		case PermissionEditor:
			return PermissionMatrix{
				CanRead:           true,
				CanCreate:         true,
				CanUpdate:         true,
				CanDelete:         false,
				CanManageUsers:    false,
				CanManageAccounts: false,
			}
		case PermissionViewer:
			return PermissionMatrix{
				CanRead:           true,
				CanCreate:         false,
				CanUpdate:         false,
				CanDelete:         false,
				CanManageUsers:    false,
				CanManageAccounts: false,
			}
		}
	}

	// Default: no permissions
	return PermissionMatrix{
		CanRead:           false,
		CanCreate:         false,
		CanUpdate:         false,
		CanDelete:         false,
		CanManageUsers:    false,
		CanManageAccounts: false,
	}
}

// CheckPermission checks if the user has a specific permission
func CheckPermission(c *gin.Context, requiredPermission string) bool {
	ctx := c.Request.Context()
	role := contextutils.GetRoleFromContext(ctx)
	permission := contextutils.GetPermissionFromContext(ctx)

	matrix := GetPermissionMatrix(role, permission)

	switch requiredPermission {
	case "read":
		return matrix.CanRead
	case "create":
		return matrix.CanCreate
	case "update":
		return matrix.CanUpdate
	case "delete":
		return matrix.CanDelete
	case "manage_users":
		return matrix.CanManageUsers
	case "manage_accounts":
		return matrix.CanManageAccounts
	default:
		return false
	}
}
