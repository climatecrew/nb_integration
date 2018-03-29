desc "Run test suite"
task default: %w[test]

desc "Run test suite"
task :test do
  sh "rspec spec"
end

desc "Run test suite"
task :spec => :test

namespace :db do
  namespace :test do
    desc "Create test database"
    task :create do
      sh "createdb nb_integration_test"
    end

    desc "Drop test database"
    task :drop do
      sh "dropdb nb_integration_test"
    end

    desc "Create test database"
    task :setup => :create

    desc "Drop test database, create test database"
    task :reset => [:drop, :create]
  end
end
