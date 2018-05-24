module BaseModel
  def self.inherited(subclass)
    DatabaseAccess.attempt do
      super
    end
  end
end
