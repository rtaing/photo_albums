class User < ApplicationRecord
  has_secure_password
  
  # For now, we only care about passwords so ignore name
  # Create two users to seed the db
  def self.create_custom(password, admin = false)
    User.create(password: password, admin: admin)
  end
  
  # Since we don't have a name, we need to iterate through the users.
  # There are only two users so this should not be a problem.
  def self.find_with_password(password)
    User.find_each do |user|
      return user if user.authenticate(password)
    end
    nil
  end
end
