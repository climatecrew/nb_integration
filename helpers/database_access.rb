module DatabaseAccess
  # this must be defined before DB constant set
  module_function def connect_options
    ENV['DB_URL']
  end

  DB = Sequel.connect(connect_options)
end
