require "rack/test"
require "logger"

require File.expand_path("../../../server.rb", __FILE__)

module RackTestHelper
  def self.included(mod)
    mod.include Rack::Test::Methods
  end

  def app
    Server.app
  end

  def test_rack_env
    {
      "rack.logger" => Logger.new("log/test.log")
    }
  end
end
