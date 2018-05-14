class HandleEventCreation
  def initialize(logger, account, payload)
    @logger = logger
    @account = account
    @payload = payload
  end

  attr_reader :logger, :account, :payload

  def call
    code = 201
    path_provider = PathProvider.new(slug: account.nb_slug,
                                     api_token: account.nb_access_token)
    payload["event"]["status"] = "published"
    payload["event"]["calendar_id"] = ENV["NB_CALENDAR_ID"].to_i
    author_email = payload["event"]["author_email"]
    payload["event"].delete("author_email")
    logger.info("Creation URL: #{path_provider.create(:events)}")
    logger.info("Sending payload:\n#{payload}")
    nb_response = Client.create(path_provider: path_provider,
                                resource: :events,
                                payload: payload)
    if nb_response.status.to_i >= 400
      logger.warn("Create Event: NationBuilder request failed. Status: #{nb_response.status} / Body: #{nb_response.body}")
      code = nb_response.status
      body = {
        errors: [
          ErrorPresenter.new(body: nb_response.body).transform.merge({ title: "Failed to create event" })
        ]
      }
    else
      nb_event = begin
                   JSON.parse(nb_response.body)
                 rescue JSON::ParserError
                   logger.warn("Create Event: Invalid JSON returned by NationBuilder: #{nb_response.body}")
                   nil
                 end

      if nb_event.nil?
        code = 500
        body = { errors: [{ title: "Failed to create event" }] }
      else
        author_id = payload
          .fetch("event")
          .fetch("author_id")
        contact_email = payload
          .fetch("event")
          .fetch("contact")
          .fetch("email")
        Event.create(nb_slug: account.nb_slug,
                     author_nb_id: author_id,
                     author_email: author_email,
                     contact_email: contact_email,
                     nb_event: nb_response.body)
        body = { data: JSON.parse(nb_response.body) }
      end
    end
    [code, body]
  end
end
