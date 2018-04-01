require "helpers/app_configuration"

class RequestOAuthAccessToken
  include AppConfiguration

  def initialize(slug:, code:)
    @slug = slug
    @code = code
  end

  attr_reader :slug, :code

  def call
    Faraday.new(url: nation_url).post do |req|
      req.url "/oauth/token"
      req.headers['Content-Type'] = 'application/json'
      req.body = access_token_request_body
    end
  end

  def nation_url
    "https://#{slug}.nationbuilder.com"
  end

  def access_token_request_body
    {
      client_id: app_client_id,
      client_secret: app_client_secret,
      redirect_uri: "#{app_base_url}/oauth/callback?slug=#{slug}",
      grant_type: "authorization_code",
      code: code
    }.to_json
  end
end
