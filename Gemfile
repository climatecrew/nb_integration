# instruct Heroku to use desired Ruby version
ruby "2.5.0"

source 'https://rubygems.org'

gem "puma"

gem 'faraday'
gem 'roda'

group :test, :development do
  gem 'dotenv'
  gem 'pry'
  gem 'rerun'
end

group :test do
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'webmock'
end
