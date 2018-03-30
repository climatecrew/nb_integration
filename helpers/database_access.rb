require 'sequel'

module DatabaseAccess
  # this must be defined before DB constant set
  module_function def connect_options
    ENV['DATABASE_URL'] or raise "DB_URL not present in environment"
  end

  DB = Sequel.connect(connect_options)
end
