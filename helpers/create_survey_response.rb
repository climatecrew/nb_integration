class CreateSurveyResponse
  include AppConfiguration

  def initialize(logger, path_provider, person_id, response_text)
    @logger = logger
    @path_provider= path_provider
    @person_id = person_id
    @response_text = response_text
  end

  attr_reader :logger, :path_provider, :person_id, :response_text

  def call
    Client.create(path_provider: path_provider,
                  resource: :survey_responses,
                  payload: payload)
  end

  private

  def payload
    {
      "survey_response": {
        "survey_id": app_event_planning_survey_id,
        "person_id": person_id,
        "is_private": true,
        "question_responses": [{
          "question_id": app_event_planning_survey_comments_question_id,
          "response": response_text
        }]
      }
    }
  end
end
