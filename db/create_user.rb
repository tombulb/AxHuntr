require 'bcrypt'
require_relative 'helpers.rb'

email = "def@def.com"
password = "password"

password_digest = BCrypt::Password.create(password)


run_sql("INSERT INTO users (email, password_digest) VALUES ('#{email}', '#{password_digest}');")



