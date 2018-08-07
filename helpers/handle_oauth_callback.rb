# frozen_string_literal: true

class HandleOAuthCallback
  def initialize(r)
    @r = r
  end

  def call
    flash_type, errors = process_parameters
    flash_type, errors = request_oauth_access_token if errors.empty?

    OpenStruct.new(
      flash_type: flash_type,
      message: message(errors),
      errors: errors
    )
  end

  private

  attr_accessor :r

  def message(errors)
    if errors.empty?
      'Installation successful'
    else
      errors.join(', ')
    end
  end

  def process_parameters
    errors = []
    flash_type = :notice

    if r.params['slug'].nil?
      flash_type = :error
      errors << 'Missing slug parameter'
    end

    if r.params['code'].nil? && r.params['error'].nil?
      flash_type = :error
      errors << 'Either code or error parameter must be given'
    end

    unless r.params['error'].nil?
      base_message = 'App not installed.'
      error_message = if r.params['error_description'].nil?
                        base_message
                      else
                        "#{base_message} #{r.params['error_description']}"
                      end
      errors << error_message
    end

    [flash_type, errors]
  end

  def request_oauth_access_token
    errors = []
    token_response = RequestOAuthAccessToken.new(
      slug: r.params['slug'],
      code: r.params['code']
    ).call

    if token_response.status != 200
      flash_type = :error
      errors << 'An error occurred when attempting to install this app in your nation. Please try again.'
    else
      flash_type = :notice
      token_response_body = JSON.parse(token_response.body)
      Account.create(nb_slug: r.params['slug'], nb_access_token: token_response_body['access_token'])
    end

    [flash_type, errors]
  end
end
