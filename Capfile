load 'deploy' if respond_to?(:namespace) # cap2 differentiator

# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'

Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy' # remove this line to skip loading any of the default tasks

namespace :deploy do

    after "deploy:assets:symlink" do
      symlink_shared
    end
    
    desc "Symbolic links the production environment and database.yml in the shared folder"
    task :symlink_shared, :hosts => "#{domain}" do
        run "ln -s #{privly_shared_path}production.rb #{latest_release}/config/environments/production.rb"
        run "ln -s #{privly_shared_path}database.yml #{latest_release}/config/database.yml"
        run "rm #{latest_release}/config/initializers/secret_token.rb"
        run "ln -s #{privly_shared_path}secret_token.rb #{latest_release}/config/initializers/secret_token.rb"
        run "cd #{privly_shared_path}ZeroBin; git pull"
        run "ln -s #{privly_shared_path}ZeroBin #{latest_release}/public/zero_bin"
        run "ln -s #{privly_shared_path}airbrake.rb #{latest_release}/config/initializers/airbrake.rb"
    end
end