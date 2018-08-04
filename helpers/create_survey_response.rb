class CreateSurveyResponse
  def initialize(logger, path_provider, response_text)
    @logger = logger
    @path_provider= path_provider
    @email = response_text
  end

  attr_reader :logger, :path_provider, :response_text

  def call
  end
end
