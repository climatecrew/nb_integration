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

      desc "Setup #{env} database"
      task :setup => :create

      desc "Reset #{env} database"
      task :reset => [:drop, :create]
    end
  end

  # default to development DB
  desc "Create development database"
  task :create => 'development:create'

  desc "Drop development database"
  task :drop => 'development:drop'

  desc "Setup development database"
  task :setup => 'development:setup'

  desc "Rest development database"
  task :reset => 'development:reset'
end
