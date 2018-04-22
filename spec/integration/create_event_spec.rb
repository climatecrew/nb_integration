require "securerandom"
require "support/rack_test_helper"
require "models/account"
require "models/event"

RSpec.describe "POST /api/events" do
  include RackTestHelper

  let(:slug) { 'test_slug' }
  let(:access_token) { SecureRandom.hex }

  context "when request is not successful" do
    it "returns 422 when missing parameters" do
      post "/api/events", {}, test_rack_env

      expect(last_response.status).to eq(422)
    end

    it "returns JSON on bad requests" do
      post "/api/events", {}, test_rack_env

      expect(last_response.headers['Content-Type']).to eq('application/json')
    end

    it "returns JSON even when the server has an error" do
      allow(test_rack_env["rack.logger"]).to receive(:info).and_raise(RuntimeError, "bad")

      post "/api/events?slug=#{slug}", {}, test_rack_env

      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect { JSON.parse(last_response.body) }.not_to raise_error
    end

    it "returns an error if no nation with the given slug exists" do
      post "/api/events?slug=#{slug}", {}, test_rack_env

      expect(last_response.status).to eq(422)

      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect { JSON.parse(last_response.body) }.not_to raise_error
      expect(JSON.parse(last_response.body)["errors"])
        .to eq([{ "title" => "nation slug '#{slug}' not recognized" }])
    end
  end

  context "when request is successful" do
    it "makes a request to NationBuilder with the formatted payload" do
      url = "https://#{slug}.nationbuilder.com/api/v1/sites/#{slug}/pages/events" \
            "?access_token=#{access_token}"
      stub_request(:post, url)
        .with("body": {})
      Account.create(nb_slug: slug, nb_access_token: access_token)

      post "/api/events?slug=#{slug}", {}, test_rack_env

      expect(a_request(:post, url)
        .with("body": {}))
        .to have_been_made.once
    end

    context "when the NationBuilder request succeeds" do
      it "writes the given event to the DB" do

      end

      it "returns the event" do
        #expect(last_response.status).to eq(201)
      end
    end

    context "when the NationBuilder request fails" do
      it "returns an error message" do
      end
    end
  end
end
