class MatchNBPerson
  def initialize(logger, path_provider, email)
    @logger = logger
    @path_provider= path_provider
    @email = email
  end

  attr_reader :logger, :path_provider, :email

  def call
    logger.info("Attempting to match person with email #{email}")
    nb_response = Client.match(path_provider: path_provider,
                               resource: :people,
                               parameters: { email: email })
    if nb_response.status >= 400
      logger.info("Could not match person person with email #{email}")
      return nil
    end

    logger.info("Person with email #{email} found")
    begin
      JSON.parse(nb_response.body)
    rescue JSON::ParserError
      logger.warn("Person match returned invalid JSON: #{nb_response.body}")
      nil
    end
  end
end
