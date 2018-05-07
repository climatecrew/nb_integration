require "logger"

$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path(File.dirname(__FILE__), "helpers/")

require "helpers/dotenv_loader"
# we need the environment variables set before requiring files
# that reference them at a file level
DotenvLoader.new.load

require "helpers/startup"
require "helpers/constants"
require "nb_integration"


if !Startup.nb_configuration_valid?
  message = "NationBuilder configuration missing. Exiting."
  Logger.new($stderr).fatal(message)
  exit CONFIGURATION_ERROR
end

use Rack::Logger
run App.freeze.app
