require "bcrypt"

class User < Sequel::Model
  one_to_many :ads
  one_to_many :comments
  one_to_many :discussions

  def password
    BCrypt::Password.new(password_hash)
  end

  def password=(new_password)
    self.password_hash = BCrypt::Password.create(new_password)
  end

  def admin?() permission == "admin" end
end
