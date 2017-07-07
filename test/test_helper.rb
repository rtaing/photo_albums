ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def add_attachments
    Photo.find_each.with_index do |photo, index|
      photo.update_attribute(:picture, fixture_file_upload("test/fixtures/files/sunscreen_#{index+1}.jpg", 'image/jpeg'))
    end
  end
  
  def remove_attachments
    FileUtils.rm_rf(Dir["#{Rails.root}/public/system/#{Rails.env}"])
  end
end

module SignInHelper
  def sign_in_with(password)
    post login_url(password: password)
  end
  
  def sign_out
    post logout_url
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end