source 'http://rubygems.org'

# Core System
gem 'rails', '~> 3.1.0'
gem 'json'
gem 'jquery-rails', "~> 2.3.0"

# Database gem
group :production do
  gem 'mysql2' # Comment out this line to use another Database type
end
group :development, :test do
  gem 'sqlite3'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "3.1.5"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

# Deploy with Capistrano
gem 'capistrano', '~> 2.15.5'

# To use debugger
# gem 'ruby-debug'

#Javascript runtime
gem 'execjs'
gem 'therubyracer'

# Authorization
gem 'cancan'

# Authentication
gem 'devise' #https://github.com/plataformatec/devise
gem 'devise_invitable', '~> 1.1.0'

# Administration interface
gem "activeadmin"

# Markdown lightweight markup language gem
gem 'rdiscount'

# Useragent inspection
gem 'useragent'

# Error reporting service
gem "airbrake"

# Jasmine testing
group :development, :test do
  gem 'jasmine'
end
