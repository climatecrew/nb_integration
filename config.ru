# frozen_string_literal: true

require 'logger'

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'dependencies'

require 'server'

unless AppConfiguration.nb_configuration_valid?
  message = 'NationBuilder configuration missing. Exiting.'
  Logger.new($stderr).fatal(message)
  exit CONFIGURATION_ERROR
end

use Rack::Logger
run Server.freeze.app
