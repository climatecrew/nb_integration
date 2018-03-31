$:.unshift File.dirname(__FILE__)
require "app_configuration"
require "database_access"

class Startup
  extend AppConfiguration
  include DatabaseAccess
end
