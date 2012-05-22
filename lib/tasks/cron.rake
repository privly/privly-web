namespace :cron do
  desc "Run all the regular maintenance tasks for the application"
  task :run_cron => :environment do
    puts "invoking db:destroy_burnt_posts"
    Rake::Task["db:destroy_burnt_posts"].invoke
  end
end
