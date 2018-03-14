# instruct Heroku to use desired Ruby version
ruby "2.5.0"

source 'https://rubygems.org'

gem "puma"

gem 'faraday'
gem 'roda'

group :test, :development do
  gem 'pry'
  gem 'rerun'
end

group :test do
  gem 'rspec'
  gem 'webmock'
end
