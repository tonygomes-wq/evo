# frozen_string_literal: true

module Api
  module V1
    module Admin
      class AccountsController < Api::BaseController
        before_action :authenticate_request!
        before_action :require_super_admin!

        # GET /api/v1/admin/accounts
        def index
          # Get all accounts from RuntimeConfig
          accounts = [RuntimeConfig.account]
          
          render json: {
            success: true,
            data: accounts.map { |acc| serialize_account(acc) }
          }
        end

        # POST /api/v1/admin/accounts
        def create
          # For now, we'll create a new entry in RuntimeConfig
          # In a full implementation, this would create a new account in the accounts table
          
          account_data = account_params.to_h
          admin_data = params[:admin]
          
          # Validate required fields
          unless admin_data && admin_data[:name] && admin_data[:email] && admin_data[:password]
            return render json: {
              success: false,
              errors: ['Admin user data is required (name, email, password)']
            }, status: :unprocessable_entity
          end
          
          # Create admin user
          begin
            admin_user = User.create!(
              name: admin_data[:name],
              email: admin_data[:email],
              password: admin_data[:password],
              password_confirmation: admin_data[:password],
              confirmed_at: Time.current,
              type: 'User'
            )
            
            # Assign account_admin role
            account_admin_role = Role.find_by!(key: 'account_admin')
            UserRole.create!(
              user: admin_user,
              role: account_admin_role
            )
            
            # For now, return success with the created admin
            # In a full implementation, we would also create the account record
            render json: {
              success: true,
              message: 'Account admin created successfully. Note: Full multi-account support requires additional database setup.',
              data: {
                admin: {
                  id: admin_user.id,
                  name: admin_user.name,
                  email: admin_user.email,
                  role: account_admin_role.key
                }
              }
            }, status: :created
          rescue ActiveRecord::RecordInvalid => e
            render json: {
              success: false,
              errors: e.record.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        # GET /api/v1/admin/accounts/:id
        def show
          account = RuntimeConfig.account
          
          # Get users with admin roles
          admin_roles = Role.where(key: ['super_admin', 'account_owner', 'account_admin'])
          users = User.joins(:user_roles)
                      .where(user_roles: { role_id: admin_roles.pluck(:id) })
                      .distinct
          
          render json: {
            success: true,
            data: {
              account: serialize_account(account),
              users: users.map { |u| serialize_user(u) },
              stats: account_stats(account)
            }
          }
        end

        # PATCH /api/v1/admin/accounts/:id
        def update
          # For now, we can only update the RuntimeConfig account
          account = RuntimeConfig.account
          
          # In a full implementation, this would update the account in the database
          render json: {
            success: true,
            message: 'Account update requires full multi-account database setup',
            data: serialize_account(account)
          }
        end

        # DELETE /api/v1/admin/accounts/:id
        def destroy
          render json: {
            success: false,
            error: 'Account deletion requires full multi-account database setup'
          }, status: :forbidden
        end

        # GET /api/v1/admin/accounts/:id/users
        def users
          # Get all users
          users = User.includes(:roles).all
          
          render json: {
            success: true,
            data: users.map { |u| serialize_user(u) }
          }
        end

        # POST /api/v1/admin/accounts/:id/users/:user_id/assign_role
        def assign_user_role
          user = User.find(params[:user_id])
          role = Role.find_by!(key: params[:role_key])
          
          # Remove existing roles
          user.user_roles.destroy_all
          
          # Assign new role
          UserRole.create!(user: user, role: role)
          
          render json: {
            success: true,
            data: serialize_user(user.reload)
          }
        rescue ActiveRecord::RecordNotFound => e
          render json: {
            success: false,
            error: e.message
          }, status: :not_found
        end

        private

        def require_super_admin!
          unless current_user.has_role?('super_admin')
            render json: {
              success: false,
              error: 'Super admin access required'
            }, status: :forbidden
          end
        end

        def account_params
          params.require(:account).permit(:name, :domain, :support_email, :locale, :status)
        end

        def serialize_account(account)
          {
            id: account['id'],
            name: account['name'],
            domain: account['domain'],
            support_email: account['support_email'],
            locale: account['locale'],
            status: account['status'],
            created_at: account['created_at'],
            updated_at: account['updated_at']
          }
        end

        def serialize_user(user)
          {
            id: user.id,
            name: user.name,
            email: user.email,
            confirmed_at: user.confirmed_at,
            roles: user.roles.map { |r| { key: r.key, name: r.name } },
            created_at: user.created_at,
            updated_at: user.updated_at
          }
        end

        def account_stats(account)
          {
            users_count: User.count,
            agents_count: 0, # TODO: Query from Core Service
            conversations_count: 0 # TODO: Query from CRM
          }
        end
      end
    end
  end
end
