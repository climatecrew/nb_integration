$:.unshift File.expand_path(File.dirname(__FILE__), "helpers/")
require "helpers/dotenv_loader"

desc "Run test suite"
task default: %w[test]

desc "Run test suite"
task :test do
  sh "rspec spec"
end

desc "Run test suite"
task :spec => :test

namespace :db do
  [:development, :test].each do |env|
    namespace env do
      desc "Create #{env} database"
      task :create do
        sh "createdb nb_integration_#{env}"
      end

      desc "Drop #{env} database"
      task :drop do
        sh "dropdb nb_integration_#{env}"
      end

      desc "Migrate #{env} database"
      task :migrate, [:version] do |t, args|
        DotenvLoader.new(environment: env).load
        require "sequel"
        Sequel.extension :migration
        db = Sequel.connect(ENV.fetch("DATABASE_URL"))
        if args[:version]
          puts "Migrating to version #{args[:version]}"
          Sequel::Migrator.run(db, "db/migrate", target: args[:version].to_i)
        else
          puts "Migrating to latest"
          Sequel::Migrator.run(db, "db/migrate")
        end
      end

      desc "Setup #{env} database"
      task :setup => [:create, :migrate]

      desc "Reset #{env} database"
      task :reset => [:drop, :setup]
    end
  end

  # default to development DB
  desc "Create development database"
  task :create => 'development:create'

  desc "Drop development database"
  task :drop => 'development:drop'

  desc "Migrate development database"
  task :migrate, [:version] do |t, args|
    Rake::Task["db:development:migrate"].invoke(*args)
  end

  desc "Setup development database"
  task :setup => 'development:setup'

  desc "Rest development database"
  task :reset => 'development:reset'
end