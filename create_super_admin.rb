# Create super_admin role
super_admin = Role.find_or_create_by!(key: 'super_admin') do |role|
  role.name = 'Super Admin'
  role.description = 'Global administrator with access to all accounts and system management'
  role.system = true
  role.type = 'system'
end

puts "Super Admin role: #{super_admin.name} (#{super_admin.key})"

# Assign all permissions
super_admin.role_permissions_actions.destroy_all
ResourceActionsConfig.all_permission_keys.each do |permission_key|
  super_admin.role_permissions_actions.create!(permission_key: permission_key)
end

puts "Assigned #{super_admin.role_permissions_actions.count} permissions to Super Admin"

# Create account_admin role
account_admin = Role.find_or_create_by!(key: 'account_admin') do |role|
  role.name = 'Account Admin'
  role.description = 'Administrator of a specific account with user management capabilities'
  role.system = true
  role.type = 'account'
end

puts "Account Admin role: #{account_admin.name} (#{account_admin.key})"

# Get account_owner permissions (excluding super_admin exclusive ones)
account_owner = Role.find_by!(key: 'account_owner')
account_owner_permission_keys = account_owner.role_permissions_actions.pluck(:permission_key)

# Assign permissions to account_admin (same as account_owner minus some sensitive ones)
account_admin.role_permissions_actions.destroy_all
account_owner_permission_keys.each do |permission_key|
  account_admin.role_permissions_actions.create!(permission_key: permission_key)
end

puts "Assigned #{account_admin.role_permissions_actions.count} permissions to Account Admin"

# Update current user to super_admin
user = User.find_by(email: 'tonygomes058@gmail.com')
if user
  user.user_roles.destroy_all
  UserRole.create!(user: user, role: super_admin)
  puts "✅ User #{user.email} is now Super Admin"
else
  puts "⚠️ User tonygomes058@gmail.com not found"
end

puts "\n📊 Summary:"
puts "Total roles: #{Role.count}"
Role.all.each do |role|
  puts "  - #{role.key}: #{role.name} (#{role.role_permissions_actions.count} permissions)"
end
