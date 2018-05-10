require "roda"
require "json"

$:.unshift File.expand_path(File.dirname(__FILE__), "helpers/")
require "helpers/path_provider"
require "helpers/client"
require "helpers/error_presenter"
require "helpers/app_configuration"
require "helpers/nb_app_install"
require "helpers/handle_oauth_callback"

$:.unshift File.expand_path(File.dirname(__FILE__), "models/")
require "models/account"
require "models/event"

class App < Roda
  include AppConfiguration

  plugin :json
  plugin :json_parser
  plugin :all_verbs
  plugin :render
  plugin :public, gzip: true, default_mime: "text/html"

  def event(event_index_response)
    data = JSON.parse(event_index_response.body)
    data["results"].first
  end

  def logger
    env["rack.logger"]
  end

  route do |r|
    # GET / request
    r.root do
      render("home", locals: { flash: {} })
    end

    # serve the app as an HTML page
    r.public

    r.on "oauth" do
      r.is "callback" do
        result = HandleOAuthCallback.new(r).call
        if result.errors.any?
          logger.warn("Request to /oauth/callback failed: Params: #{r.params}. Errors: #{result.message}")
        end
        r.redirect("/install?flash[#{result.flash_type}]=#{CGI::escape(result.message)}")
      end
    end

    r.on "install" do
      r.is do
        r.get do
          flash = if r.params["flash"]
                    r.params["flash"]
                  else
                    {}
                  end
          render("home", locals: { flash: flash })
        end

        r.post do
          slug = r.params['slug']
          unless slug.nil? || slug.empty?
            nb_install_url = NBAppInstall.new(slug: slug).url
            r.redirect(nb_install_url)
          else
            r.redirect("/install?flash[error]=slug+is+missing")
          end
        end
      end
    end

    r.on "api" do
      response["Allow"] = "GET, HEAD, POST, PUT"
      response["Access-Control-Allow-Origin"] = "*"
      response["Access-Control-Allow-Headers"] = "Accept, Accept-Language, Content-Language, Content-Type"

      r.options do
        {}
      end

      @response_body = {}
      r.is "events" do
        begin
          slug = r.params["slug"]
          unless slug.nil?
            account = Account.first(nb_slug: slug)
            if account.nil?
              response.status =  422
              @response_body = { errors: [{title: "nation slug '#{slug}' not recognized"}] }
            else
              r.post do
                logger.info("Attempting to create event for nation #{slug}")
                response.status =  201
                path_provider = PathProvider.new(slug: account.nb_slug,
                                                 api_token: account.nb_access_token)
                payload = r.params['data']
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
                  response.status = nb_response.status
                                 @response_body = {
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
                    response.status = 500
                    @response_body = { errors: [{ title: "Failed to create event" }] }
                  else
                    author_id = payload
                      .fetch("event")
                      .fetch("author_id")
                    contact_email = payload
                      .fetch("event")
                      .fetch("contact")
                      .fetch("email")
                    Event.create(nb_slug: slug,
                                 author_nb_id: author_id,
                                 author_email: author_email,
                                 contact_email: contact_email,
                                 nb_event: nb_response.body)
                    @response_body = { data: JSON.parse(nb_response.body) }
                  end
                end
              end

              r.get do
                response.status =  200
                conditions = { nb_slug: slug }
                if !r.params["author_nb_id"].nil?
                  conditions[:author_nb_id] = r.params["author_nb_id"]
                end
                events = Event.where(conditions)
                nb_events = events.map { |event| JSON.parse(event.nb_event) }
                @response_body = { data: nb_events }
              end
            end
          else
            response.status =  422
            @response_body = { errors: [{title: "missing slug parameter"}] }
          end
        rescue => error
          logger.warn(error)
          response.status = 500
        end
        @response_body
      end
    end
  end
end
