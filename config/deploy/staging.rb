server 'dev.privly.org', :app, :web, :primary => true
set :domain, "dev.privly.org"
role :web, "dev.privly.org"                          # Your HTTP server, Apache/etc
role :app, "dev.privly.org"                          # This may be the same as your `Web` server
role :db,  "dev.privly.org", :primary => true # This is where Rails migrations will run

set :branch, "master"
