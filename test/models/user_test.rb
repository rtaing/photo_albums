require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "reject incorrect password" do
    user = User.find_with_password("incorrect")
    assert_nil user
  end
  
  test "can authenticate user" do
    user = User.find_with_password("password")
    assert user
  end
  
  test "can authenticate admin user" do
    user = User.find_with_password("admin")
    assert user && user.admin
  end
  
  test "can manually add users" do
    assert_difference('User.count') do
      User.create_custom("newadmin", true)
    end
    user = User.find_with_password("newadmin")
    assert user && user.admin
  end
end
