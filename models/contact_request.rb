# frozen_string_literal: true

require 'sequel'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__), '../models/')
require 'base_model'

class ContactRequest < Sequel::Model
  include BaseModel
end
