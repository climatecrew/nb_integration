require 'sequel'

module DatabaseAccess
  # this must be defined before setting DB constant below
  # class level expressions execute when file is loaded
  module_function def connect_options
    ENV['DATABASE_URL'] or raise "DATABASE_URL not present in environment"
  end

  module_function def connect
    attempts ||= 1
    if attempts > 1
      puts "Attempt #{attempts}: connecting to DB"
    end
    Sequel.connect(connect_options)
  rescue => e
    wait_time = 0.5
    attempts += 1
    if attempts <= 3
      puts "DB connection failed. Sleeping for #{wait_time} seconds and retrying"
      sleep wait_time
      retry
    else
      puts "Could not connect after #{attempts} attempts. Giving up."
      raise e
    end
  end

  module_function def disconnect
    DB.disconnect
  rescue => e
    puts "DB disconnect failed: #{e}"
  end

  module_function def database
    disconnect
    DB
  end

  unless const_defined?(:DB)
    DB = connect
  end

  # DB connection must exist for plugin activation to work
  Sequel::Model.plugin :timestamps, update_on_create: true
end
