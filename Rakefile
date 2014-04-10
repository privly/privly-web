#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Privly::Application.load_tasks

task :travis do
  ["rake jasmine:ci"].each do |cmd|
    puts "Starting to run #{cmd}"
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $?.exitstatus == 0
  end
end
