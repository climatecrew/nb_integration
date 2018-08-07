# frozen_string_literal: true

module AppConfiguration
  module_function

  def nb_configuration_valid?
    !ENV['NB_CLIENT_ID'].to_s.empty? &&
      !ENV['NB_CLIENT_SECRET'].to_s.empty? &&
      !ENV['NB_POINT_PERSON_ID'].to_s.empty? &&
      !ENV['NB_EVENT_PLANNING_SURVEY_ID'].to_s.empty? &&
      !ENV['NB_EVENT_PLANNING_SURVEY_COMMENTS_QUESTION_ID'].to_s.empty?
  end

  def log_nb_configuration_error(logger)
    logger.warn("ENV['NB_CLIENT_ID'] unset.") if ENV['NB_CLIENT_ID'].to_s.empty?

    if ENV['NB_CLIENT_SECRET'].to_s.empty?
      logger.warn("ENV['NB_CLIENT_SECRET'] unset.")
    end

    if ENV['NB_POINT_PERSON_ID'].to_s.empty?
      logger.warn("ENV['NB_POINT_PERSON_ID'] unset.")
    end
  end

  def domain_name
    ENV['DOMAIN_NAME']
  end

  def protocol
    ENV['HTTP_PROTOCOL'] || 'https'
  end

  def app_base_url
    "#{protocol}://#{domain_name}"
  end

  def app_client_id
    ENV['NB_CLIENT_ID']
  end

  def app_client_secret
    ENV['NB_CLIENT_SECRET']
  end

  def app_point_person_id
    ENV['NB_POINT_PERSON_ID']
  end

  def app_event_planning_survey_id
    ENV['NB_EVENT_PLANNING_SURVEY_ID'].to_i
  end

  def app_event_planning_survey_comments_question_id
    ENV['NB_EVENT_PLANNING_SURVEY_COMMENTS_QUESTION_ID'].to_i
  end
end
