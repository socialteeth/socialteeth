require "bcrypt"

class User < Sequel::Model
  one_to_many :ads

  def password
    BCrypt::Password.new(password_hash)
  end

  def password=(new_password)
    self.password_hash = BCrypt::Password.create(new_password)
  end
end
