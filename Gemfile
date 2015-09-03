source 'http://rubygems.org'

# Core System
gem 'rails', '~> 3.2.0'
gem 'json'
gem 'jquery-rails'

# Database gem
gem 'mysql2' # Comment out this line to use another Database type
# gem 'sqlite3'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', '>=1.0.3'
end

group :test do
  gem 'selenium-webdriver'
end

# Records test coverage
gem "codeclimate-test-reporter", group: :test, require: nil

group :test, :development do
  gem 'sauce', '~> 3.5.6'
  gem 'sauce-connect'
  gem 'capybara', '~> 2.4.4'
end

# Deploy with Capistrano
gem 'capistrano', '~> 2.15.5'

# To use debugger
# gem 'ruby-debug'

#Javascript runtime
gem 'execjs'
gem 'therubyracer'

# Authentication
gem 'devise' #https://github.com/plataformatec/devise

# This version is currently required for Devise 3+ on Rails 3.2
gem 'devise_invitable', '= 1.2.1'

# Administration interface
gem "activeadmin"

# Markdown lightweight markup language gem
gem 'rdiscount'

# Useragent inspection
gem 'useragent'

# Error reporting service
gem "airbrake"

# Support Ruby 1.9.3
gem 'cmdparse', '= 2.0.6'
