# Script para atualizar usuário no Rails
user = User.find('c3c911c4-d18e-47a0-8f25-51a8903a50d5')
user.email = 'tonygomes058@gmail.com'
user.uid = 'tonygomes058@gmail.com'
user.password = 'To811205ny@'
user.password_confirmation = 'To811205ny@'
user.save!
puts "Usuário atualizado com sucesso!"
puts "Email: #{user.email}"
puts "UID: #{user.uid}"
