require "sequel"

$:.unshift File.expand_path(File.dirname(__FILE__), "../helpers/")
require "helpers/database_access"

class Account < Sequel::Model
end
