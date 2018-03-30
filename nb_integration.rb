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

class App < Roda
  include AppConfiguration

  plugin :json
  plugin :render

  def event(event_index_response)
    data = JSON.parse(event_index_response.body)
    data["results"].first
  end

  def logger
    env["rack.logger"]
  end

  route do |r|
    # NationBuilder API URL provider
    @path_provider = PathProvider.new(slug: nb_slug,
                                      api_token: nb_api_token)
    # GET / request
    r.root do
      render("home", locals: { flash: {} })
    end

    r.on "event" do
      r.is do
        r.get do
          # fetch events, show the first one
          response = Client.index(path_provider: @path_provider, resource: :events)
          if response.status != 200
            {
              errors: [message: "Unexpected response from NationBuilder"]
            }
          else
            event = event(response)
            {
              id: event["id"],
              name: event["name"],
              intro: event["intro"],
              status: event["status"],
              start_time: event["start_time"],
              end_time: event["end_time"]
            }
          end
        end

        # POST /event request
        r.post do
          # just for this demo we're trusting the input from the client as-is
          Client.update(path_provider: @path_provider,
                        resource: :events,
                        id: r.params["event"]["id"],
                        payload: r.params)

          r.redirect
        end
      end
    end

    r.on "oauth" do
      r.is "callback" do
        errors = []
        if r.params["slug"].nil?
          errors << { "title" => "slug parameter is missing" }
        end

        if r.params["code"].nil?
          errors << { "title" => "code parameter is missing" }
        end

        if errors.any?
          response.status = 422
          { "errors" => errors }
        else
          token_response = RequestOAuthAccessToken.new(
            slug: r.params["slug"],
            code: r.params["code"]
          ).call

          if token_response.status != 200
            response.status = 500
            {
              "errors" => [{"title" => "An error occurred when attempting to obtain an access token from NationBuilder. Please try again."}]
            }
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
  end
end
