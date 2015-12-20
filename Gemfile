source 'http://rubygems.org'

# Core System
gem 'rails', '~> 4.2.0'
gem 'json'
gem 'jquery-rails'

# Database gem
gem 'mysql2' # Comment out this line to use another Database type
# gem 'sqlite3'

group :test do
  gem 'selenium-webdriver'
  gem 'minitest'
end

# Records test coverage
gem "codeclimate-test-reporter", group: :test, require: nil

group :development do
  gem 'web-console', '~> 2.0'
end

group :test, :development do
  gem 'sauce', '~> 3.5.6'
  gem 'sauce-connect'
  gem 'capybara', '~> 2.4.4'
end

# Deploy with Capistrano
gem 'capistrano', '~> 2.15.5'

# To use debugger
# gem 'ruby-debug'

# Authentication
gem 'devise' #https://github.com/plataformatec/devise

# This version is currently required for Devise 3+ on Rails 3.2
gem 'devise_invitable'

# Administration interface
gem 'activeadmin', '~> 1.0.0.pre2'

# Markdown lightweight markup language gem
gem 'rdiscount'

# Useragent inspection
gem 'useragent'

group :production do
  # Error reporting service
  gem "airbrake"
end

# Test Coverage
gem 'coveralls', require: false

# may be required on OSX
#brew install libxml2 ####libxslt libiconv
