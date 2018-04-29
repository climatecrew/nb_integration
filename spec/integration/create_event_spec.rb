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
    let(:url) do
      "https://#{slug}.nationbuilder.com/api/v1/sites/#{slug}/pages/events" \
      "?access_token=#{access_token}"
    end
    let(:event_body) do
      <<~JSON
        {
          "event": {
            "name": "Day of Action"
          }
        }
      JSON
    end

    let(:client_event) { JSON.parse(event_body) }
    let(:forwarded_event) do
      base_event = client_event["event"]
      {
        "event" => base_event.merge(
          "status" => "published",
          "calendar_id" => ENV["NB_CALENDAR_ID"].to_i
        )
      }
    end

    let(:nb_event_body) do
      forwarded_event.merge(
        "id" => 12
      )
    end

    before do
      Account.create(nb_slug: slug, nb_access_token: access_token)
    end

    it "makes a request to NationBuilder with the formatted payload" do
      stub_request(:post, url).with(body: forwarded_event)

      post "/api/events?slug=#{slug}", { "data" => client_event }, test_rack_env

      expect(a_request(:post, url)
        .with("body": forwarded_event))
        .to have_been_made.once
    end

    context "when the NationBuilder request succeeds" do
      it "writes the created event to the DB" do
        stub_request(:post, url).with(body: forwarded_event)
          .to_return(body: JSON.generate(nb_event_body))

        post "/api/events?slug=#{slug}", { "data" => client_event }, test_rack_env

        expect(Event.count).to eq(1)
        expect(JSON.parse(Event.first.nb_event)).to eq(nb_event_body)
      end

      it "returns 201 and the event" do
        stub_request(:post, url).with(body: forwarded_event)
          .to_return(body: JSON.generate(nb_event_body))

        post "/api/events?slug=#{slug}", { "data" => client_event }, test_rack_env

        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to match_json_expression({
          "data" => nb_event_body
        })
      end
    end

    context "when the NationBuilder request fails" do
      it "returns an error message" do
        stub_request(:post, url).with(body: forwarded_event )
          .to_return(status: 404, body: "{}")

        post "/api/events?slug=#{slug}", { "data" => client_event }, test_rack_env

        expect(last_response.status).to eq(404)
        expect(JSON.parse(last_response.body)).to match_json_expression({
          "errors" => [{ "title": "Failed to create event", "detail": nil }]
        })
      end

      it "handles non-JSON responses from NationBuilder" do
        stub_request(:post, url).with(body: forwarded_event )
          .to_return(status: 200, body: "<html><body>Gateway Timeout</body></html>")

        post "/api/events?slug=#{slug}", { "data" => client_event }, test_rack_env

        expect(last_response.status).to eq(500)
        expect(JSON.parse(last_response.body)).to match_json_expression({
          "errors" => [{ "title": "Failed to create event" }]
        })
      end
    end
  end
end
