# instruct Heroku to use desired Ruby version
ruby "2.5.0"

source 'https://rubygems.org'

gem 'faraday'
gem 'sequel'
gem 'pg'
gem 'puma'
gem 'rake'
gem 'roda'
gem 'tilt'


group :test, :development do
  gem 'dotenv'
  gem 'pry'
  gem 'rerun'
end

group :test do
  gem 'database_cleaner'
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'warning'
  gem 'webmock'
end