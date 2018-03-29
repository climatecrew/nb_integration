module DatabaseAccess
  DB = 1

  module_function def db_user
    ENV['DB_USER'] || ENV['USER']
  end

  module_function def db_password
    ENV['DB_PASSWORD']
  end

  module_function def db_url
    "postgres://#{db_user}:#{db_password}@localhost:5432/db_name"
  end
end
