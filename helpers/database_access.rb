require 'sequel'

module DatabaseAccess
  # this must be defined before setting DB constant below
  # class level expressions execute when file is loaded
  module_function def connect_options
    ENV['DATABASE_URL'] or raise "DATABASE_URL not present in environment"
  end

  DB = Sequel.connect(connect_options)

  # DB connection must exist for plugin activation to work
  Sequel::Model.plugin :timestamps, update_on_create: true
end
