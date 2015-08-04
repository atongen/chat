require File.expand_path('../config/environment', __FILE__)
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :db do
  desc "Run migrations"
  task :migrate do |t, args|
    Sequel.extension :migration
    if ENV['VERSION']
      puts "Migrating to version #{ENV['VERSION']}"
      Sequel::Migrator.run(Chat::DB, "db/migrations", target: ENV['VERSION'].to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(Chat::DB, "db/migrations")
    end
  end
end
