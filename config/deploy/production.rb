server 'privlyalpha.org', :app, :web, :primary => true
set :domain, "privlyalpha.org"
role :web, "privlyalpha.org"                          # Your HTTP server, Apache/etc
role :app, "privlyalpha.org"                          # This may be the same as your `Web` server
role :db,  "privlyalpha.org", :primary => true # This is where Rails migrations will run

set :branch, "master"
