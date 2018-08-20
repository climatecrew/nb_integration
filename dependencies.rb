# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__), 'helpers/')
# we need the environment variables set before requiring files
# that reference them at a file level
require 'helpers/dotenv_loader'
DotenvLoader.new.load

require 'helpers/app_configuration'
Dir["helpers/*"].each { |file| require file }

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__), 'models/')
Dir["models/*"].each { |file| require file }
