# frozen_string_literal: true

# instruct Heroku to use desired Ruby version
ruby '2.5.1'

source 'https://rubygems.org'

gem 'faraday'
gem 'pg'
gem 'puma'
gem 'rake'
gem 'roda'
gem 'sequel'
gem 'tilt'

group :test, :development do
  gem 'dotenv'
  gem 'pry'
  gem 'rerun'
  gem 'rubocop', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'json_expressions'
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'warning'
  gem 'webmock'
end
