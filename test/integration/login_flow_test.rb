require 'test_helper'

class LoginFlowTest < ActionDispatch::IntegrationTest
  test "should show login again if password is incorrect" do
    post sessions_url(password: 'incorrect')
    assert_nil session[:user_id]
    assert flash[:error]
    assert_redirected_to login_url
    follow_redirect!
    assert_select 'div#error', flash[:error] 
  end
  
  test "correct password shows albums" do
    post sessions_url(password: 'password')
    assert session[:user_id]
    assert_redirected_to albums_path
  end
  
end
