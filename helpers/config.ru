require "logger"

$:.unshift File.dirname(__FILE__)
require "startup"
require "web"
require "constants"

if !Startup.nb_configuration_valid?
  message = "Configuration missing: NB_API_TOKEN and NB_SLUG must be set in ENV. Exiting."
  Logger.new($stderr).fatal(message)
  exit CONFIGURATION_ERROR
end

use Rack::Logger
run App.freeze.app
