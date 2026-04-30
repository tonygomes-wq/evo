require 'bcrypt'

password = 'To811205ny@'
encrypted = BCrypt::Password.create(password)
puts encrypted
