source "https://rubygems.org"

ruby "~> 3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.0"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem 'guard'
  gem 'guard-rspec', require: false
end

# --- TEMPLATE START ---
gem 'simple_form'
gem 'wobapphelpers', git: 'https://github.com/swobspace/wobapphelpers',
                   branch: 'master'
gem 'rails-i18n', '~> 7.0.0'
gem 'view_component'
gem 'cancancan'
gem "wobauth", git: "https://github.com/swobspace/wobauth.git", branch: "master"

group :test, :development do
  gem 'rspec-rails'
  gem 'dotenv'
  # gem 'json_spec', require: false
end

group :test do
  gem "shoulda-matchers", require: false
  gem 'factory_bot_rails'
  gem "capybara"
  gem 'selenium-webdriver'
  gem 'webdriver'
  gem 'launchy'
end
# --- TEMPLATE END ---

gem "faker", "~> 3.3", :groups => [:test, :development]

gem "faraday", "~> 2.9"

gem "nori", "~> 2.7"

gem "savon", "~> 2.15"

gem "immutable_struct", "~> 1.2"

gem "net-ping", "~> 2.0"

gem "good_job", "~> 4.7.0"

gem "acts_as_list", "~> 1.1"

gem "liquid", "~> 5.5"

gem "pagy", "~> 9.0"

gem "highline", "~> 3.0", require: false

gem "faye-websocket", "~> 0.11.3"

gem "eventmachine", "~> 1.2"

gem "faraday-cookie_jar", "~> 0.0.7"

gem "faraday-net_http_persistent", "~> 2.3"
