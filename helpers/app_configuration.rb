module AppConfiguration
  def nb_configuration_valid?
    ENV['NB_CLIENT_ID'].to_s.length > 0 && ENV['NB_CLIENT_SECRET'].to_s.length > 0
  end
  module_function :nb_configuration_valid?

  def log_nb_configuration_error(logger)
    if ENV['NB_CLIENT_ID'].to_s.empty?
      logger.warn("ENV['NB_CLIENT_ID'] unset.")
    end

    if ENV['NB_CLIENT_SECRET'].to_s.empty?
      logger.warn("ENV['NB_CLIENT_SECRET'] unset.")
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
end
