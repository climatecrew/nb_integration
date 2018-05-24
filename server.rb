require "roda"
require "json"

$:.unshift File.expand_path(File.dirname(__FILE__), "helpers/")
require "helpers/path_provider"
require "helpers/client"
require "helpers/error_presenter"
require "helpers/app_configuration"
require "helpers/nb_app_install"
require "helpers/handle_oauth_callback"
require "helpers/handle_event_creation"

$:.unshift File.expand_path(File.dirname(__FILE__), "models/")
require "models/account"
require "models/event"

class Server < Roda
  include AppConfiguration

  plugin :json
  plugin :json_parser
  plugin :all_verbs
  plugin :render
  plugin :public, gzip: true, default_mime: "text/html"
  plugin :halt

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

    # for testing serve client-app as a static HTML page from the public directory
    # conversely when installed in a nation we expect the admin to
    # embed a JavaScript snippet to pull the app into the page of their choice
    r.public

    # enable an administrator to install this app in their nation
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

    # process OAuth callbacks from NationBuilder, primarily to store access tokens
    r.on "oauth" do
      r.is "callback" do
        result = HandleOAuthCallback.new(r).call
        if result.errors.any?
          logger.warn("Request to /oauth/callback failed: Params: #{r.params}. Errors: #{result.message}")
        end
        r.redirect("/install?flash[#{result.flash_type}]=#{CGI::escape(result.message)}")
      end
    end

    # load JavaScript app for embed on nation web page
    r.on "embed" do
      slug = r.params["slug"]
      callback = r.params["callback"]

      response["Content-Type"] = "application/javascript"
      render("events", locals: { slug: slug, callback: callback })
    end

    # JSON interface to this app's functionality
    r.on "api" do
      begin
        response["Allow"] = "GET, HEAD, POST, PUT"
        response["Access-Control-Allow-Origin"] = "*"
        response["Access-Control-Allow-Headers"] = "Accept, Accept-Language, Content-Language, Content-Type"

        r.options do
          {}
        end

        r.is "health" do
          if r.params["raise_error"] == "true"
            raise RuntimeError.new("Health check endpoint: raise test error")
          else
            {
              data: {
                id: 1,
                type: "health_check",
                attributes: { status: "OK" }
              }
            }
          end
        end

        r.is "events" do
          slug = r.params["slug"]
          if slug.nil?
            r.halt(422, { errors: [{title: "missing slug parameter"}] })
          else
            account = Account.first(nb_slug: slug)
            r.halt(422, { errors: [{title: "nation slug '#{slug}' not recognized"}] }) if account.nil?
          end

          r.post do
            logger.info("Attempting to create event for nation #{slug}")
            payload = r.params['data']
            code, body = HandleEventCreation.new(logger, account, payload).call
            response.status = code
            body
          end

          r.get do
            conditions = { nb_slug: slug }
            conditions[:author_nb_id] = r.params["author_nb_id"] unless r.params["author_nb_id"].nil?

            events = Event.where(conditions)

            response.status =  200
            { data: events.map { |event| JSON.parse(event.nb_event) } }
          end
        end
      rescue => error
        logger.warn(error)
        response.status = 500
        { errors: [{title: "An unexpected error has occurred."}] }
      end
    end
  end
end
