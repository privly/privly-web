# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Privly::Application.initialize!

#returns just the html from the markdown
Mime::Type.register "text/html", :markdown

#returns a document for an iframe
Mime::Type.register "text/html", :iframe