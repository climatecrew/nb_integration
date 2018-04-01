require "support/rack_test_helper"

RSpec.describe "POST /api/events" do
  include RackTestHelper

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
      allow(Account).to receive(:where).and_raise(RuntimeError, "bad")

      post "/api/events?slug=test", {}, test_rack_env

      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect { JSON.parse(last_response.body) }.not_to raise_error
    end
  end

  context "when request is successful" do
    it "returns 201" do
      slug = 'test_slug'

      post "/api/events?slug=#{slug}", {}, test_rack_env

      expect(last_response.status).to eq(201)
    end
  end
end
