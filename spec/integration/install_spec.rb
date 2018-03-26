require "support/rack_test_helper"
require "helpers/nb_app_install"

RSpec.describe "/install" do
  include RackTestHelper

  describe "GET /install" do
    it "returns 200" do
      get "/install"

      expect(last_response.status).to eq(200)
    end
  end

  describe "POST /install" do
    it "redirects to the NationBuilder OAuth request URL" do
      test_slug = "slug"
      nb_install_url = NBAppInstall.new(slug: test_slug).url

      post "/install", { "slug" => test_slug }

      expect(last_response.status).to eq(302)
      expect(last_response["Location"]).to eq(nb_install_url)
    end

    context "when slug not entered" do
      it "redirects to /install with a flash error message" do
        post "/install"

        expect(last_response.status).to eq(302)
        expect(last_response["Location"]).to eq("/install?flash[error]=slug+is+missing")
      end
    end
  end
end
