package middleware

import (
	"context"
	"errors"
	"fmt"
	"net/http"

	"evo-ai-core-service/internal/httpclient/response"
	"evo-ai-core-service/internal/types"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// TenantContextKey is the key used to store the resolved account ID in the request context
const TenantContextKey = "account_id"

type TenantMiddleware interface {
	GetTenantMiddleware() gin.HandlerFunc
}

type tenantMiddleware struct{}

func NewTenantMiddleware() TenantMiddleware {
	return &tenantMiddleware{}
}

func (m *tenantMiddleware) GetTenantMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Extract accounts from context (populated by EvoAuthMiddleware)
		accountsVal := c.Request.Context().Value("accounts")
		if accountsVal == nil {
			fmt.Printf("TenantMiddleware: No accounts found in context\n")
			response.ErrorResponse(c, "UNAUTHORIZED", "User has no associated accounts", nil, http.StatusUnauthorized)
			c.Abort()
			return
		}

		accounts, ok := accountsVal.([]types.EvoAuthAccount)
		if !ok || len(accounts) == 0 {
			fmt.Printf("TenantMiddleware: Accounts list is empty or invalid type\n")
			response.ErrorResponse(c, "UNAUTHORIZED", "User has no active accounts", nil, http.StatusUnauthorized)
			c.Abort()
			return
		}

		var resolvedAccountID uuid.UUID

		// Check if user explicitly requested a specific tenant via header
		requestedTenant := c.GetHeader("X-Tenant-ID")
		if requestedTenant != "" {
			reqID, err := uuid.Parse(requestedTenant)
			if err != nil {
				response.ErrorResponse(c, "INVALID_TENANT", "Invalid X-Tenant-ID format", nil, http.StatusBadRequest)
				c.Abort()
				return
			}

			// Validate that the user actually belongs to this requested tenant
			found := false
			for _, acc := range accounts {
				if acc.ID == reqID {
					resolvedAccountID = acc.ID
					found = true
					break
				}
			}

			if !found {
				fmt.Printf("TenantMiddleware: User requested access to account %s but does not belong to it\n", reqID)
				response.ErrorResponse(c, "FORBIDDEN", "You do not have access to the requested tenant", nil, http.StatusForbidden)
				c.Abort()
				return
			}
		} else {
			// Default to the first account
			resolvedAccountID = accounts[0].ID
		}

		// Inject the resolved account_id into the context
		ctx := context.WithValue(c.Request.Context(), TenantContextKey, resolvedAccountID)
		c.Request = c.Request.WithContext(ctx)

		c.Next()
	}
}

// GetTenantID is a helper function to retrieve the current tenant ID from the Gin context
func GetTenantID(c *gin.Context) (uuid.UUID, error) {
	val := c.Request.Context().Value(TenantContextKey)
	if val == nil {
		return uuid.Nil, errors.New("account_id not found in context")
	}

	accountID, ok := val.(uuid.UUID)
	if !ok {
		return uuid.Nil, errors.New("account_id in context is not a valid UUID")
	}

	return accountID, nil
}
