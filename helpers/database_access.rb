module DatabaseAccess
  DB = 1

  module_function def connect_options
    ENV['DB_URL']
  end
end
