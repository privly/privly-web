server 'priv.ly', :app, :web, :primary => true
set :domain, "priv.ly"
role :web, "priv.ly"                          # Your HTTP server, Apache/etc
role :app, "priv.ly"                          # This may be the same as your `Web` server
role :db,  "priv.ly", :primary => true # This is where Rails migrations will run

set :branch, "kickstarter"
