require_relative "boot"

require "rails"
require "rails/all"

# Pick the frameworks you want:
#require "active_model/railtie"
#require "active_job/railtie"
#require "active_record/railtie"
#require "active_storage/engine"
#require "action_controller/railtie"
#require "action_mailer/railtie"
#require "action_mailbox/engine"
#require "action_text/engine"
#require "action_view/railtie"
#require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load dotenv only in development or test environment
if ['development', 'test'].include? ENV['RAILS_ENV']
  Dotenv::Rails.load
end

module Cocard
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks templates))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil
    config.generators do |g|
      g.assets            false
      g.helper            false
      g.test_framework    :rspec
      g.jbuilder          false
    end

    config.after_initialize do
      Rails.application.reload_routes!
    end

    unless Rails.env.test?
      config.active_job.queue_adapter = :good_job
      config.active_job.queue_name_prefix = "cocard_#{Rails.env}"
    end

    config.responders.error_status = :unprocessable_entity
    config.responders.redirect_status = :see_other
  end
end
