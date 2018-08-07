# frozen_string_literal: true

class HandleContactRequestCreation
  def initialize(logger, account, payload)
    @logger = logger
    @account = account
    @payload = payload
    @path_provider = PathProvider.new(slug: account.nb_slug,
                                      api_token: account.nb_access_token)
  end

  attr_reader :logger, :account, :payload, :path_provider

  def call
    person_id = try_person_id(payload)
    notes = payload['notes']
    notes = notes.to_s.empty? ? nil : notes

    forwarded_payload = if person_id
                          prepare_payload(payload, :update)
                        else
                          prepare_payload(payload, :create)
                        end

    logger.info("Sending payload:\n#{forwarded_payload}")
    nb_response = make_api_request(person_id, forwarded_payload)
    if nb_response.status.to_i >= 400
      code, body = on_failure(nb_response)
    else
      code, body = on_success(nb_response, notes)
    end
    [code, body]
  end

  private

  def try_person_id(payload)
    person_id = payload['person']['id']
    if person_id.nil?
      person = MatchNBPerson.new(logger, path_provider, payload['person']['email']).call
      person_id = person['person']['id'] if person
    end
    person_id
  end

  def prepare_payload(payload, request_type)
    present_optional_fields = {}
    %w[phone mobile work_phone_number].each do |key|
      if payload['person'][key].nil?
        payload['person'].delete(key)
      else
        present_optional_fields[key] = payload['person'][key]
      end
    end

    if request_type == :update
      {
        'person' => {
          'tags' => ['Prep Week September 2018'],
          'parent_id' => AppConfiguration.app_point_person_id.to_i
        }.merge(present_optional_fields)
      }
    else
      required_create_fields = %w[first_name last_name email].each_with_object({}) do |key, hash|
        hash[key] = payload['person'][key]
      end

      {
        'person' => {
          'tags' => ['Prep Week September 2018'],
          'parent_id' => AppConfiguration.app_point_person_id.to_i
        }.merge(present_optional_fields)
          .merge(required_create_fields)
      }
    end
  end

  def make_api_request(person_id, forwarded_payload)
    if person_id
      Client.update(path_provider: path_provider,
                    resource: :people,
                    id: person_id,
                    payload: forwarded_payload)
    else
      Client.create(path_provider: path_provider,
                    resource: :people,
                    payload: forwarded_payload)
    end
  end

  def on_success(nb_response, notes)
    nb_person = begin
                 JSON.parse(nb_response.body)
               rescue JSON::ParserError
                 logger.warn("Create Event: Invalid JSON returned by NationBuilder: #{nb_response.body}")
                 nil
               end
    if nb_person.nil?
      code = 500
      body = { errors: [{ title: 'Failed to create contact request' }] }
    else
      code = 201
      nb_user_id = nb_person
                   .fetch('person')
                   .fetch('id')
      nb_user_email = payload
                      .fetch('person')
                      .fetch('email')
      contact_request = ContactRequest.create(nb_slug: account.nb_slug,
                                              nb_user_id: nb_user_id,
                                              nb_user_email: nb_user_email,
                                              nb_person: nb_response.body,
                                              notes: notes)
      # we use a NationBuilder survey to make the notes visible in the control panel
      CreateSurveyResponse.new(logger, path_provider, contact_request).call

      body = { data: nb_person }
    end
    [code, body]
  end

  def on_failure(nb_response)
    logger.warn("Create Event: NationBuilder request failed. Status: #{nb_response.status} / Body: #{nb_response.body}")

    [
      nb_response.status,
      { errors: [ErrorPresenter.new(body: nb_response.body).transform.merge(title: 'Failed to create contact request')] }
    ]
  end
end
