package contextutils

import (
	"context"
	"fmt"

	"github.com/google/uuid"
)

// GetAccountIDFromContext extracts the account_id from the request context.
// Returns uuid.Nil if not found or if user is Super Admin without X-Account-Id header.
func GetAccountIDFromContext(ctx context.Context) uuid.UUID {
	accountID, ok := ctx.Value("account_id").(uuid.UUID)
	if !ok {
		return uuid.Nil
	}
	return accountID
}

// IsSuperAdmin checks if the authenticated user has super_admin role.
func IsSuperAdmin(ctx context.Context) bool {
	role, ok := ctx.Value("role").(string)
	return ok && role == "super_admin"
}

// GetUserIDFromContext extracts the user_id from the request context.
func GetUserIDFromContext(ctx context.Context) (uuid.UUID, error) {
	userID, ok := ctx.Value("user_id").(uuid.UUID)
	if !ok {
		return uuid.Nil, fmt.Errorf("user_id not found in context")
	}
	return userID, nil
}

// GetUserEmailFromContext extracts the email from the request context.
func GetUserEmailFromContext(ctx context.Context) (string, error) {
	email, ok := ctx.Value("email").(string)
	if !ok {
		return "", fmt.Errorf("email not found in context")
	}
	return email, nil
}

// ShouldFilterByAccount determines if queries should be filtered by account_id.
// Returns false only for Super Admin users without a specific account_id set.
func ShouldFilterByAccount(ctx context.Context) bool {
	// If user is Super Admin and no account_id is set, don't filter
	if IsSuperAdmin(ctx) {
		accountID := GetAccountIDFromContext(ctx)
		return accountID != uuid.Nil
	}
	// All other users must be filtered by account
	return true
}

// ValidateAccountAccess checks if the resource's account_id matches the user's account_id.
// Returns nil if access is allowed, error otherwise.
func ValidateAccountAccess(ctx context.Context, resourceAccountID *uuid.UUID) error {
	// Super Admin can access any account
	if IsSuperAdmin(ctx) {
		return nil
	}

	// Resource must have an account_id
	if resourceAccountID == nil {
		return fmt.Errorf("resource has no account association")
	}

	// User's account_id must match resource's account_id
	userAccountID := GetAccountIDFromContext(ctx)
	if userAccountID == uuid.Nil {
		return fmt.Errorf("user has no account context")
	}

	if *resourceAccountID != userAccountID {
		return fmt.Errorf("resource not found") // Don't expose cross-tenant access attempts
	}

	return nil
}
