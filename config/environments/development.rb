Privly::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # Set this variable to change the displayed name of the site.
  config.name = "Site Name"

  # The host new injectible links should be created on.
  # You should generally set this to the domain of your server
  config.link_domain_host = "localhost:3000"

  config.action_mailer.default_url_options = { :host => 'localhost' }
  
  # Required protocol, choose "http" or "https"
  config.required_protocol = "http"
  
  # Don't send invitations to users by default.
  # Setting this to false will send users
  # accounts when they sign up for invitations,
  # while setting it to true will send them
  # a message that the system is currently in closed Alpha.
  config.send_invitations = false

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :logger

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

end
