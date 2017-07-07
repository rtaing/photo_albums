require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  
  test "should ask for password if not logged in" do
    get new_session_url
    assert_select 'input#password'
  end

  test "correct password is not admin user" do
    post sessions_url(password: 'password')
    assert session[:user_id]
    user = User.find(session[:user_id])
    assert_equal user.admin, false
  end

  test "correct admin password has admin user" do
    post sessions_url(password: 'admin')
    assert session[:user_id]
    user = User.find(session[:user_id])
    assert_equal user.admin, true
  end
  
  test "should log out user" do
    post logout_url
    assert_nil session[:user_id]
    assert_redirected_to login_url
  end
  
end
