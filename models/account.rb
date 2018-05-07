require "sequel"

$:.unshift File.expand_path(File.dirname(__FILE__), "../models/")
require "base_model"

class Account < Sequel::Model
  include BaseModel
end
