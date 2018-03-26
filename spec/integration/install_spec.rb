require "support/rack_test_helper"

RSpec.describe "/install" do
  include RackTestHelper

  describe "GET /install" do
    it "returns 200" do
      get "/install"

      expect(last_response.status).to eq(200)
    end
  end

  describe "POST /install" do
    it "returns 201" do
      post "/install", { "slug" => "test_slug" }

      expect(last_response.status).to eq(201)
    end

    context "when slug not entered" do
      it "returns 422" do
        post "/install"

        expect(last_response.status).to eq(422)
      end
    end
  end
end
