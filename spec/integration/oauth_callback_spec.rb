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

  let(:access_token_success_response) do
    {
      "access_token": "a44bdfe7972f7a83f5dc485cd3a7c7d2d09b0c60828ed24657c0b61e186ed93a",
      "token_type": "bearer",
      "scope":""
    }
  end

  context "missing parameters" do
    it "requires slug" do
      get "/oauth/callback?code=#{authorization_code}", test_rack_env

      expect(last_response.status).to eq(422)
      expect(JSON.parse(last_response.body)).to eq(
        {
          "errors" => [{"title" => "slug parameter is missing"}]
        }
      )
    end

    it "requires code" do
      get "/oauth/callback?slug=#{nation_slug}", test_rack_env

      expect(last_response.status).to eq(422)
      expect(JSON.parse(last_response.body)).to eq(
        {
          "errors" => [{"title" => "code parameter is missing"}]
        }
      )
    end
  end

  context "when required parameters supplied" do
    it "attempts to exchange the authorization code for an access token" do
      token_request = stub_request(:post, "https://#{nation_slug}.nationbuilder.com/oauth/token").
        with(access_token_request).
        to_return({
          headers: { "Content-Type" => "application/json" },
          body: access_token_success_response.to_json
        })

      get "/oauth/callback?slug=#{nation_slug}&code=#{authorization_code}", test_rack_env

      expect(token_request).to have_been_requested.once
    end

    context "when NationBuilder does not provide a successful token response" do
      it "returns an error message" do
        access_token_failure_response = "<!DOCTYPE html><html><body>An error has occurred</body></html>"
        stub_request(:post, "https://#{nation_slug}.nationbuilder.com/oauth/token").
          with(access_token_request).
          to_return({
            status: 404,
            headers: { "Content-Type" => "text/html" },
            body: access_token_failure_response
          })

        get "/oauth/callback?slug=#{nation_slug}&code=#{authorization_code}", test_rack_env

        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(500)

        expect(JSON.parse(last_response.body)).to eq(
          {
            "errors" => [{"title" => "An error occurred when attempting to obtain an access token from NationBuilder. Please try again."}]
          }
        )
      end
    end

    context "when NationBuilder provides a successful token response" do
      it "redirects to /install with a success message" do
        stub_request(:post, "https://#{nation_slug}.nationbuilder.com/oauth/token").
          with(access_token_request).
          to_return({
            headers: { "Content-Type" => "application/json" },
            body: access_token_success_response.to_json
          })

        get "/oauth/callback?slug=#{nation_slug}&code=#{authorization_code}", test_rack_env

        expect(last_response.status).to eq(302)
        expect(last_response["Location"]).to eq("/install?flash[notice]=Installation+successful")
      end

      it "writes to slug and token to the database" do
        stub_request(:post, "https://#{nation_slug}.nationbuilder.com/oauth/token").
          with(access_token_request).
          to_return({
            headers: { "Content-Type" => "application/json" },
            body: access_token_success_response.to_json
          })

        get "/oauth/callback?slug=#{nation_slug}&code=#{authorization_code}", test_rack_env

        account = Account.first
        expect(account.nb_access_token).to eq(access_token_success_response["access_token"])
      end
    end
  end
end
