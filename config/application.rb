require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PhotoAlbums
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    
    # File system storage
    # config.paperclip_defaults = {
    #   storage: :filesystem,
    #   url: "/system/:rails_env/:class/:attachment/:id_partition/:style/:filename",
    # }

    # S3 storage
    # config.paperclip_defaults = {
    #   :storage => :s3,
    #   :s3_credentials => {
    #     :bucket => ENV['S3_BUCKET'],
    #     :access_key_id => ENV['S3_KEY'],
    #     :secret_access_key => ENV['S3_SECRET'],
    #     :s3_region => 'us-west-2'
    #   },
    #   :s3_headers =>  { "Content-Type" => "application/octet-stream" },
    #   path: ":class/:style/:id/:basename.:extension",
    #   url: ":s3_domain_url"
    # }
  end
end
