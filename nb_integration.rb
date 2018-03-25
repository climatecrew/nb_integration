require "roda"
require "json"

$:.unshift File.expand_path(File.dirname(__FILE__), "helpers/")
require "helpers/path_provider"
require "helpers/client"
require "helpers/app_configuration"

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
          response = Client.update(path_provider: @path_provider,
                                   resource: :events,
                                   id: r.params["event"]["id"],
                                   payload: r.params)

          r.redirect
        end
      end
    end

    r.on "oauth" do
      r.is "callback" do
        authorization_code = r.params["code"]
        slug = "test_nation_slug"
        nation_url = "https://#{slug}.nationbuilder.com"
        client_secret = "app_client_secret"
        client_id = "app_client_id"
        access_token_request_path = "/oauth/token"
        access_token_request_body = {
          client_id: client_id,
          client_secret: client_secret,
          redirect_uri: "#{app_base_url}/oauth/callback?slug=#{slug}",
          grant_type: "authorization_code",
          code: authorization_code
        }.to_json

        conn = Faraday.new(url: nation_url)
        response = conn.post do |req|
          req.url access_token_request_path
          req.headers['Content-Type'] = 'application/json'
          req.body = access_token_request_body
        end

        logger.info("code: #{authorization_code}")
        { code: authorization_code }
      end
    end
  end
end
