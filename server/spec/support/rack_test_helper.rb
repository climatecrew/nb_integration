require "rack/test"
require "logger"

require File.expand_path("../../../nb_integration.rb", __FILE__)

module RackTestHelper
  def self.included(mod)
    mod.include Rack::Test::Methods
  end

  def app
    App.app
  end

  def test_rack_env
    {
      "rack.logger" => Logger.new("log/test.log")
    }
  end
end
