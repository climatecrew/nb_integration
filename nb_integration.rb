require "roda"
require "json"

$:.unshift File.expand_path(File.dirname(__FILE__), "helpers/")
require "helpers/path_provider"
require "helpers/client"
require "helpers/app_configuration"
require "helpers/request_oauth_access_token"

class App < Roda
  include AppConfiguration

  plugin :json

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
      r.redirect "/event"
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
          response = RequestOAuthAccessToken.new(
            slug: r.params["slug"],
            code: r.params["code"]
          ).call

          { code: r.params["code"] }
        end
      end
    end
  end
end
