# frozen_string_literal: true

require 'logger'

class DotenvLoader
  def initialize(environment: ENV['APP_ENVIRONMENT']&.to_sym || :development)
    @environment = environment.to_sym
  end

  attr_reader :environment

  def load
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
    Logger.new($stderr).info('Could not load dotenv. Will not use Dotenv to set environment variables.')
  end
end
