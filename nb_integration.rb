require "roda"
require "json"

$:.unshift File.expand_path(File.dirname(__FILE__), "helpers/")
require "helpers/path_provider"
require "helpers/client"
require "helpers/app_configuration"
require "helpers/request_oauth_access_token"
require "helpers/nb_app_install"

$:.unshift File.expand_path(File.dirname(__FILE__), "models/")
require "models/account"
require "models/event"

class App < Roda
  include AppConfiguration

  plugin :json
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
        errors = []
        if r.params["slug"].nil?
          errors << "Missing slug parameter"
        end

        if r.params["code"].nil? && r.params["error"].nil?
          errors << "Either code or error parameter must be given"
        end

        if errors.any?
          message = errors.join(', ')
          logger.warn("Unexpected request to /oauth/callback: #{r.params}. Errors: #{message}")
          r.redirect("/install?flash[error]=#{CGI::escape(message)}")
        else
          if r.params["error"].nil?
            token_response = RequestOAuthAccessToken.new(
              slug: r.params["slug"],
              code: r.params["code"]
            ).call
          else
            base_message = "#{CGI::escape('App not installed.')}"
            if r.params["error_description"].nil?
              message = base_message
            else
              message = "#{base_message}+#{CGI::escape(r.params['error_description'])}"
            end
            r.redirect("/install?flash[notice]=#{message}")
          end

          if token_response.status != 200
            message = "An error occurred when attempting to install this app in your nation. Please try again."
            r.redirect("/install?flash[error]=#{CGI::escape(message)}")
          else
            token_response_body = JSON.parse(token_response.body)
            Account.create(nb_slug: r.params["slug"], nb_access_token: token_response_body["access_token"])
            r.redirect("/install?flash[notice]=Installation+successful")
          end
        end
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
      # NationBuilder API URL provider
      @path_provider = PathProvider.new(slug: nb_slug,
                                        api_token: nb_api_token)
      r.is "events" do
        begin
          unless r.params["slug"].nil?
            Account.where(nb_slug: r.params["slug"])

            r.post do
              response.status =  201
              {}
            end

            r.get do
              response.status =  200
              events = Event.where(nb_slug: r.params["slug"])
              nb_events = events.map { |event| JSON.parse(event.nb_event) }
              { data: nb_events }
            end
          else
            response.status =  422
          end
        rescue => error
          logger.warn(error)
          response.status = 500
        end
        {}
      end
    end
  end
end
