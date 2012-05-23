require "bcrypt"

class User < Sequel::Model
  def before_create
    self.created_at ||= Time.now
    super
  end

  def password
    BCrypt::Password.new(password_hash)
  end

  def password=(new_password)
    self.password_hash = BCrypt::Password.create(new_password)
  end
end
