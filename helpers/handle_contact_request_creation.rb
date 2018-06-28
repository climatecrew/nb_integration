class HandleContactRequestCreation
  def initialize(logger, account, payload)
    @logger = logger
    @account = account
    @payload = payload
  end

  attr_reader :logger, :account, :payload

  def call
    path_provider = PathProvider.new(slug: account.nb_slug,
                                     api_token: account.nb_access_token)
    person_id = payload["person"].delete("id")
    forwarded_payload = prepare_payload(payload)
    logger.info("Sending payload:\n#{forwarded_payload}")
    nb_response = if person_id
                    Client.update(path_provider: path_provider,
                                  resource: :people,
                                  id: person_id,
                                  payload: forwarded_payload)
                  else
                    Client.create(path_provider: path_provider,
                                  resource: :people,
                                  payload: forwarded_payload)
                  end
    if nb_response.status.to_i >= 400
      code, body = on_failure(nb_response)
    else
      code, body = on_success(nb_response)
    end
    [code, body]
  end

  private

  def prepare_payload(payload)
    payload["person"]["tags"] = ["Prep Week September 2018"]
    payload["person"]["parent_id"] = AppConfiguration.app_point_person_id.to_i
    payload
  end

  def on_success(nb_response)
    nb_person = begin
                 JSON.parse(nb_response.body)
               rescue JSON::ParserError
                 logger.warn("Create Event: Invalid JSON returned by NationBuilder: #{nb_response.body}")
                 nil
               end
    if nb_person.nil?
      code = 500
      body = { errors: [{ title: "Failed to create contact request" }] }
    else
      code = 201
      nb_user_id = nb_person
        .fetch("person")
        .fetch("id")
      nb_user_email = payload
        .fetch("person")
        .fetch("email")
      ContactRequest.create(nb_slug: account.nb_slug, nb_user_id: nb_user_id, nb_user_email: nb_user_email, nb_person: nb_response.body)
      body = { data: nb_person }
    end
    [code, body]
  end

  def on_failure(nb_response)
    logger.warn("Create Event: NationBuilder request failed. Status: #{nb_response.status} / Body: #{nb_response.body}")

    [
      nb_response.status,
      { errors: [ErrorPresenter.new(body: nb_response.body).transform.merge({ title: "Failed to create contact request" })] }
    ]
  end
end
