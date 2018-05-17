require "securerandom"
require "support/rack_test_helper"

RSpec.describe "Requests to /api/*" do
  include RackTestHelper

  let(:slug) { 'test_slug' }
  let(:access_token) { SecureRandom.hex }

  let(:api_test_rack_env) do
    test_rack_env.merge("CONTENT_TYPE" => "application/json")
  end

  describe "OPTIONS /api" do
    it "sends back an Allow header" do
      options "/api", {}, test_rack_env

      expect(last_response.status).to eq(200)
      expect(last_response.headers["Allow"]).to eq("GET, HEAD, POST, PUT")
      expect(last_response.headers["Access-Control-Allow-Origin"]).to eq("*")
      expect(last_response.headers["Access-Control-Allow-Headers"])
        .to eq("Accept, Accept-Language, Content-Language, Content-Type")
    end
  end

  describe "GET /api/health" do
    it "returns 200" do
      get "/api/health", {}, test_rack_env

      expect(last_response.status).to eq(200)
    end

    it "returns a JSON response" do
      get "/api/health", {}, test_rack_env

      expect { JSON.parse(last_response.body) }.not_to raise_error
    end
  end

  context "when request is not successful" do
    it "returns JSON when an unexpected error occurs" do
      get "/api/health?raise_error=true", {}, test_rack_env

      expect(last_response.status).to eq(500)
      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect(JSON.parse(last_response.body)).to eq(
        { "errors" => [{ "title" => "An unexpected error has occurred." } ] }
      )
    end
  end
end
