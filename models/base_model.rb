$:.unshift File.expand_path(File.dirname(__FILE__), "../helpers/")
require "helpers/database_access"

module BaseModel
  def self.inherited(subclass)
    DatabaseAccess.attempt do
      super
    end
  end
end
