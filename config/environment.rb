# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Privly::Application.initialize!

Mime::Type.register "text/plain", :gm
Mime::Type.register "text/html", :iframe