$:.unshift File.expand_path("../helpers", __FILE__)
#$:.unshift File.dirname(__FILE__)
#$:.unshift File.expand_path(File.dirname(__FILE__), "helpers/")

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  require "helpers/database_access"
end