source 'http://rubygems.org'
ruby "2.2.4"

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
  gem 'test-unit' # For selenium test cases
end

# Records test coverage
gem "codeclimate-test-reporter", group: :test, require: nil

group :development do
  gem 'web-console', '~> 2.0'
end

group :production do
  gem "airbrake" # Error reporting service
  gem 'therubyracer' # JavaScript runtime
end

group :development, :production do
  gem "capistrano-rails" # Deploy with Capistrano
  gem 'capistrano-passenger'
  gem 'capistrano-git-submodule-strategy', '~> 0.1', :github => 'ekho/capistrano-git-submodule-strategy', :ref => "e3b8a78fbe7d3f7d03d473ee488a9c805f8f6fac"
end

group :test, :development do
  gem 'sauce', '~> 3.5.6'
  gem 'sauce-connect'
  gem 'capybara', '~> 2.4.4'
end

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


# Test Coverage
gem 'coveralls', require: false

# may be required on OSX
#brew install libxml2 ####libxslt libiconv
