# frozen_string_literal: true

class HandleEventCreation
  def initialize(logger, account, payload)
    @logger = logger
    @account = account
    @payload = payload
  end

  attr_reader :logger, :account, :payload

  def call
    path_provider = PathProvider.new(slug: account.nb_slug,
                                     api_token: account.nb_access_token)
    author_email = payload['event'].delete('author_email')
    forwarded_payload = prepare_payload(payload)
    logger.info("Sending payload:\n#{forwarded_payload}")
    nb_response = Client.create(path_provider: path_provider,
                                resource: :events,
                                payload: forwarded_payload)
    if nb_response.status.to_i >= 400
      code, body = on_failure(nb_response)
    else
      code, body = on_success(nb_response, author_email)
    end
    [code, body]
  end

  private

  def prepare_payload(payload)
    payload['event']['status'] = 'published'
    payload['event']['calendar_id'] = ENV['NB_CALENDAR_ID'].to_i
    payload
  end

  def on_success(nb_response, author_email)
    nb_event = begin
                 JSON.parse(nb_response.body)
               rescue JSON::ParserError
                 logger.warn("Create Event: Invalid JSON returned by NationBuilder: #{nb_response.body}")
                 nil
               end

    if nb_event.nil?
      code = 500
      body = { errors: [{ title: 'Failed to create event' }] }
    else
      code = 201
      author_id = payload
                  .fetch('event')
                  .fetch('author_id')
      contact_email = payload
                      .fetch('event')
                      .fetch('contact')
                      .fetch('email')
      Event.create(nb_slug: account.nb_slug,
                   author_nb_id: author_id,
                   author_email: author_email,
                   contact_email: contact_email,
                   nb_event: nb_response.body)

      body = { data: nb_event }
    end

    [code, body]
  end

  def on_failure(nb_response)
    logger.warn("Create Event: NationBuilder request failed. Status: #{nb_response.status} / Body: #{nb_response.body}")

    errors = ErrorPresenter.new(nb_response.body).to_h
    errors['errors'].each do |error|
      error.merge!(title: 'Failed to create event')
    end

    [nb_response.status, errors]
  end
end
