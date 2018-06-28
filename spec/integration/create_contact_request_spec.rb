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

  context "when request is successful" do
    let(:url) do
      "https://#{slug}.nationbuilder.com/api/v1/people" \
      "?access_token=#{access_token}"
    end

    let(:nb_user_id) { 45 }
    let(:nb_user_email) { "nbuser@example.com" }
    let(:contact_email) { "contact@example.com" }
    let(:body) do
      <<~JSON
        {
          "person": {
            "first_name": "Sadie",
            "last_name": "Brewis",
            "email": "#{contact_email}",
            "phone": "555-123-4567"
          }
        }
      JSON
    end

    let(:hash_body) { { "data" => JSON.parse(body) } }
    let(:client_body) { JSON.generate(hash_body) }
    let(:forwarded_person) do
      base_body = hash_body["data"]
      {
        "person" => base_body["person"].merge(
          "parent_id" => ENV["NB_POINT_PERSON_ID"].to_i,
          "tags": ["Prep Week September 2018"]
        )
      }
    end

    let(:nb_person_body) do
      forwarded_person
    end

    before do
      Account.create(nb_slug: slug, nb_access_token: access_token)
    end

    it "makes a request to NationBuilder with the formatted payload" do
      stub_request(:post, url).with(body: forwarded_person)

      post "/api/contact_requests?slug=#{slug}", client_body, api_test_rack_env

      expect(a_request(:post, url)
        .with("body": forwarded_person))
        .to have_been_made.once
    end

    context "when the NationBuilder request succeeds" do
      it "returns 201 and the person payload" do
        stub_request(:post, url).with(body: forwarded_person)
          .to_return(body: JSON.generate(nb_person_body))

        post "/api/contact_requests?slug=#{slug}", client_body, api_test_rack_env

        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to match_json_expression({
          "data" => forwarded_person
        })
      end
    end

    context "when the NationBuilder request fails" do
      it "returns an error message" do
        stub_request(:post, url).with(body: forwarded_person )
          .to_return(status: 404, body: "{}")

        post "/api/contact_requests?slug=#{slug}", client_body, api_test_rack_env

        expect(last_response.status).to eq(404)
        expect(JSON.parse(last_response.body)).to match_json_expression({
          "errors" => [{ "title": "Failed to create contact request", "detail": nil }]
        })
      end

      it "handles non-JSON responses from NationBuilder" do
        stub_request(:post, url).with(body: forwarded_person )
          .to_return(status: 200, body: "<html><body>Gateway Timeout</body></html>")

        post "/api/contact_requests?slug=#{slug}", client_body, api_test_rack_env

        expect(last_response.status).to eq(500)
        expect(JSON.parse(last_response.body)).to match_json_expression({
          "errors" => [{ "title": "Failed to create contact request" }]
        })
      end
    end
  end
end