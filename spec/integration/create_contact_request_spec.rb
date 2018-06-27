require "securerandom"
require "support/rack_test_helper"
require "models/account"

RSpec.describe "POST /api/contact_requests" do
  include RackTestHelper

  let(:slug) { 'test_slug' }
  let(:access_token) { SecureRandom.hex }

  let(:api_test_rack_env) do
    test_rack_env.merge("CONTENT_TYPE" => "application/json")
  end

  context "when request is not successful" do
    it "returns 422 when missing parameters" do
      post "/api/contact_requests", {}, test_rack_env

      expect(last_response.status).to eq(422)
    end

    it "returns JSON on bad requests" do
      post "/api/contact_requests", {}, test_rack_env

      expect(last_response.headers['Content-Type']).to eq('application/json')
    end

    it "returns JSON even when the server has an error" do
      allow(Account).to receive(:first).and_raise(RuntimeError, "bad")

      post "/api/contact_requests?slug=#{slug}", {}, test_rack_env

      expect(Account).to have_received(:first)
      expect(last_response.status).to eq(500)
      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect { JSON.parse(last_response.body) }.not_to raise_error
    end

    it "returns an error if no nation with the given slug exists" do
      post "/api/contact_requests?slug=#{slug}", {}, test_rack_env

      expect(last_response.status).to eq(422)

      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect { JSON.parse(last_response.body) }.not_to raise_error
      expect(JSON.parse(last_response.body)["errors"])
        .to eq([{ "title" => "nation slug '#{slug}' not recognized" }])
    end
  end
end
