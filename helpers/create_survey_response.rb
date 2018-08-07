# frozen_string_literal: true

class CreateSurveyResponse
  include AppConfiguration

  def initialize(logger, path_provider, contact_request)
    @logger = logger
    @path_provider = path_provider
    @contact_request = contact_request
  end

  attr_reader :logger, :path_provider, :contact_request

  def call
    nb_response = Client.create(path_provider: path_provider,
                                resource: :survey_responses,
                                payload: payload)
    survey_response = begin
                        JSON.generate(JSON.parse(nb_response.body.to_s))
                      rescue JSON::ParserError => error
                        logger.warn("#{self.class.name}##{__callee__}: obtained invalid JSON when creating NB survey response: #{nb_response.body}")
                        nil
                      end
    contact_request.update(nb_survey_response: survey_response)
  rescue StandardError => error
    logger.warn("#{self.class.name}##{__callee__}: survey response creation failed: #{error}")
  end

  private

  def person_id
    contact_request.nb_user_id
  end

  def response_text
    contact_request.notes
  end

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
