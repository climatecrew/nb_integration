module NBConfiguration
  def nb_api_token
    ENV['NB_API_TOKEN']
  end

  def nb_slug
    ENV['NB_SLUG']
  end

  def nb_configuration_valid?
    ENV['NB_API_TOKEN'].to_s.length > 0 && ENV['NB_SLUG'].to_s.length > 0
  end

  def log_nb_configuration_error(logger)
    if ENV['NB_API_TOKEN'].to_s.empty?
      logger.warn("ENV['NB_API_TOKEN'] unset.")
    end

    if ENV['NB_SLUG'].to_s.empty?
      logger.warn("ENV['NB_SLUG'] unset.")
    end
  end
end
