require "support/rack_test_helper"
require "helpers/app_configuration"

RSpec.describe "GET /oauth/callback" do
  include RackTestHelper
  include AppConfiguration

  let(:authorization_code) { "007" }
  let(:nation_slug) { "test_nation_slug" }
  let(:access_token_request_body) do
    {
      client_id: app_client_id,
      client_secret: app_client_secret,
      redirect_uri: "#{app_base_url}/oauth/callback?slug=#{nation_slug}",
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

  context "missing parameters" do
    it "requires slug" do
      get "/oauth/callback?code=#{authorization_code}", body_params, test_rack_env

      expect(last_response.status).to eq(422)
      expect(JSON.parse(last_response.body)).to eq(
        {
          "errors" => [{"title" => "slug parameter is missing"}]
        }
      )
    end

    it "requires code" do
      get "/oauth/callback?slug=#{nation_slug}", body_params, test_rack_env

      expect(last_response.status).to eq(422)
      expect(JSON.parse(last_response.body)).to eq(
        {
          "errors" => [{"title" => "code parameter is missing"}]
        }
      )
    end
  end

  it "returns 200" do
    stub_request(:post, "https://#{nation_slug}.nationbuilder.com/oauth/token").
      with(access_token_request)

    get "/oauth/callback?slug=#{nation_slug}&code=#{authorization_code}", body_params, test_rack_env

    expect(last_response).to be_ok
  end

  it "exchanges the authorization code for an access token" do
    token_request = stub_request(:post, "https://#{nation_slug}.nationbuilder.com/oauth/token").
      with(access_token_request)

    get "/oauth/callback?slug=#{nation_slug}&code=#{authorization_code}", body_params, test_rack_env

    expect(token_request).to have_been_requested.once
  end
end
