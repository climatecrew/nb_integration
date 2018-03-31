class DotenvLoader
  def initialize(environment: :development)
    @environment = environment.to_sym
  end

  attr_reader :environment

  def load
    begin
      require 'dotenv'
      Dotenv.load('.env')
      # If this file is present we want it to override ENV variables
      Dotenv.overload('.env.local')

      case environment
      when :development
        Dotenv.overload('.env.development.local')
      when :test
        Dotenv.overload('.env.test.local')
      end
    rescue LoadError
      Logger.new($stderr).info("Could not load dotenv. Will not use Dotenv to set environment variables.")
    end
  end
end
