require "rack/test"
require "logger"
require File.expand_path("../../../nb_integration.rb", __FILE__)

RSpec.describe "GET /oauth/callback" do
  include Rack::Test::Methods
  def app
    App.app
  end

  let(:authorization_code) { "007" }
  let(:nation_slug) { "test_nation_slug" }
  let(:client_id) { "app_client_id" }
  let(:client_secret) { "app_client_secret" }
  let(:access_token_request_body) do
    {
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: "http://x.com",
      grant_type: "authorization_code",
      code: authorization_code
    }
  end
  let(:access_token_request) do
    {
      body: access_token_request_body,
      headers: {"Content-Type" => "application/json"}
    }
  end
  let(:body_params) { {} }
  let(:rack_env) do
    {
      "rack.logger" => Logger.new("log/test.log")
    }
  end

  it "returns 200" do
    stub_request(:post, "https://#{nation_slug}.nationbuilder.com/oauth/token").
      with(access_token_request)

    get "/oauth/callback?code=#{authorization_code}", body_params, rack_env

    expect(last_response).to be_ok
  end

  it "exchanges the authorization code for an access token" do
    token_request = stub_request(:post, "https://#{nation_slug}.nationbuilder.com/oauth/token").
      with(access_token_request)

    get "/oauth/callback?code=#{authorization_code}", body_params, rack_env

    expect(token_request).to have_been_requested.once
  end
end
