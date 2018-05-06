require 'sequel'

module DatabaseAccess
  # this must be defined before setting DB constant below
  # class level expressions execute when file is loaded
  module_function def connect_options
    ENV['DATABASE_URL'] or raise "DATABASE_URL not present in environment"
  end

  module_function def connect
    attempt("connect") do
      Sequel.connect(connect_options)
    end
  end

  module_function def database
    DB
  end

  module_function def attempt(operation)
    wait_time = 1
    max_attempts = 3
    attempts ||= 1
    yield
  rescue Sequel::DatabaseDisconnectError, Sequel::DatabaseConnectionError => e
    if attempts <= max_attempts
      attempts += 1
      $stderr.puts "Database connection error: #{e}"
      $stderr.puts ""
      $stderr.puts "Sleeping for #{wait_time}s and retrying"
      $stderr.puts "=" * 80
      sleep wait_time
      retry
    else
      $stderr.puts "Could not #{operation} after #{max_attempts} attempts. Giving up."
      raise e
    end
  end

  unless const_defined?(:DB)
    DB = connect
  end

  # DB connection must exist for plugin activation to work
  Sequel::Model.plugin :timestamps, update_on_create: true
end
