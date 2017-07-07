require "test_helper"
require "capybara/poltergeist"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :poltergeist
  
  setup do
    add_attachments
  end
  
  teardown do
    remove_attachments
  end
  
  private
  
    def login_and_visit(path)
      visit path
      login_as_admin
      assert_current_path path
    end
  
    def login_as_admin
      assert_current_path login_path
      fill_in :password, with: 'admin'
      click_on 'Go'
    end

end
