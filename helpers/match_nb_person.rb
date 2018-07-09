class MatchNBPerson
  def initialize(logger, path_provider, email)
    @logger = logger
    @path_provider= path_provider
    @email = email
  end

  attr_reader :logger, :path_provider, :email

  def call
    Client.match(path_provider: path_provider,
                 resource: :people,
                 parameters: { email: email })
  end
end
