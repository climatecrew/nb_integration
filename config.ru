require "logger"
require 'dotenv'
Dotenv.load('.env')
# If this file is present we want it to override ENV variables
Dotenv.overload('.env.local')

$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path(File.dirname(__FILE__), "helpers/")

require "helpers/startup"
require "helpers/constants"
require "nb_integration"

if !Startup.nb_configuration_valid?
  message = "Configuration missing: NB_API_TOKEN and NB_SLUG must be set in ENV. Exiting."
  Logger.new($stderr).fatal(message)
  exit CONFIGURATION_ERROR
end

use Rack::Logger
run App.freeze.app
