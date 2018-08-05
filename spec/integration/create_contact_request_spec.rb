
require "securerandom"
require "support/rack_test_helper"

RSpec.describe "POST /api/contact_requests" do
  include RackTestHelper

  let(:slug) { 'test_slug' }
  let(:access_token) { SecureRandom.hex }

  let(:api_test_rack_env) do
    test_rack_env.merge("CONTENT_TYPE" => "application/json")
  end

  def stub_match_nb_person(return_value)
    match_nb_person = MatchNBPerson.new(nil, nil, nb_user_email)
    allow(MatchNBPerson).to receive(:new).and_return(match_nb_person)
    allow(match_nb_person).to receive(:call).and_return(return_value)
  end

  def stub_survey_response_creation(return_value)
    url = "https://#{slug}.nationbuilder.com/api/v1/survey_responses" \
          "?access_token=#{access_token}"
    stub_request(:post, url).to_return(body: return_value)
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
    let(:post_url) do
      "https://#{slug}.nationbuilder.com/api/v1/people" \
      "?access_token=#{access_token}"
    end

    let(:put_url) do
      "https://#{slug}.nationbuilder.com/api/v1/people/45" \
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
            "email": "#{nb_user_email}",
            "phone": "555-123-4567"
          },
          "notes": "Tell me about the cheesecake"
        }
      JSON
    end

    let(:hash_create_body) { { "data" => JSON.parse(body) } }
    let(:client_create_body) { JSON.generate(hash_create_body) }

    let(:hash_update_body) do
      update_body = JSON.parse(body)
      update_body["person"]["id"] = nb_user_id
      { "data" =>  update_body }
    end
    let(:client_update_body) { JSON.generate(hash_update_body) }

    let(:forwarded_create_person) do
      base_body = hash_create_body["data"]
      {
        "person" => base_body["person"].merge(
          "parent_id" => ENV["NB_POINT_PERSON_ID"].to_i,
          "tags" => ["Prep Week September 2018"]
        )
      }
    end

    let(:forwarded_update_person) do
      {
        "person" => {
          "parent_id" => ENV["NB_POINT_PERSON_ID"].to_i,
          "tags" => ["Prep Week September 2018"],
          "phone": "555-123-4567"
        }
      }
    end

    let(:nb_person_body) do
      {
        "person" => forwarded_create_person["person"].merge("id" => nb_user_id)
      }
    end

    before do
      Account.create(nb_slug: slug, nb_access_token: access_token)
    end

    context "when the user does not exist in NationBuilder yet" do
      it "makes a create request to NationBuilder with the formatted payload" do
        stub_match_nb_person(nil)
        stub_request(:post, post_url).with(body: forwarded_create_person)

        post "/api/contact_requests?slug=#{slug}", client_create_body, api_test_rack_env

        expect(a_request(:post, post_url)
          .with("body": forwarded_create_person))
          .to have_been_made.once
      end
    end

    context "when the user already exists in NationBuilder" do
      it "makes an update request to NationBuilder with the formatted payload" do
        stub_request(:put, put_url).with(body: forwarded_update_person)

        post "/api/contact_requests?slug=#{slug}", client_update_body, api_test_rack_env

        expect(a_request(:put, put_url)
          .with("body": forwarded_update_person))
          .to have_been_made.once
      end
    end

    context "when the NationBuilder person request succeeds" do
      it "writes the created contact_request to the DB" do
        stub_match_nb_person(nil)
        stub_survey_response_creation(nil)
        stub_request(:post, post_url).with(body: forwarded_create_person)
          .to_return(body: JSON.generate(nb_person_body))

        post "/api/contact_requests?slug=#{slug}", client_create_body, api_test_rack_env

        expect(ContactRequest.count).to eq(1)
        stored_contact_request = ContactRequest.first
        expect(JSON.parse(stored_contact_request.nb_person)).to eq(nb_person_body)
        expect(stored_contact_request.nb_user_id).to eq(nb_user_id)
        expect(stored_contact_request.nb_user_email).to eq(nb_user_email)
        expect(stored_contact_request.notes).to eq("Tell me about the cheesecake")
      end

      it "converts empty notes to NULL" do
        stub_match_nb_person(nil)
        stub_survey_response_creation(nil)
        stub_request(:post, post_url).with(body: forwarded_create_person)
          .to_return(body: JSON.generate(nb_person_body))

        body_without_notes = JSON.parse(client_create_body)
        body_without_notes["data"].delete("notes")
        post "/api/contact_requests?slug=#{slug}", JSON.generate(body_without_notes), api_test_rack_env

        expect(ContactRequest.count).to eq(1)
        stored_contact_request = ContactRequest.first
        expect(stored_contact_request.notes).to be_nil
      end

      it "writes the survey response to the created contact_request" do
        stub_match_nb_person(nil)
        survey_response = {
            "survey_response" => {
              "id" => 6,
              "updated_at" => "2018-08-04T17:41:50-04:00",
              "created_at" => "2018-08-04T17:41:50-04:00",
              "survey_id" => 68,
              "person_id" => 381,
              "is_private" => true,
              "question_responses" => [{
                "id" => 1,
                "question_id" => 502,
                "response" => "Tell me about the cheesecake"
              }]
            }
          }
        stub_survey_response_creation(JSON.generate(survey_response))
        stub_request(:post, post_url).with(body: forwarded_create_person)
          .to_return(body: JSON.generate(nb_person_body))

        post "/api/contact_requests?slug=#{slug}", client_create_body, api_test_rack_env
        stored_contact_request = ContactRequest.first
        expect(JSON.parse(stored_contact_request.nb_survey_response)).to eq(survey_response)
      end

      it "returns 201 and the person payload" do
        stub_match_nb_person(nil)
        stub_survey_response_creation(nil)
        stub_request(:post, post_url).with(body: forwarded_create_person)
          .to_return(body: JSON.generate(nb_person_body))

        post "/api/contact_requests?slug=#{slug}", client_create_body, api_test_rack_env

        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)).to match_json_expression({
          "data" => nb_person_body
        })
      end
    end

    context "when the NationBuilder person request fails" do
      it "returns an error message" do
        stub_match_nb_person(nil)
        stub_request(:post, post_url).with(body: forwarded_create_person )
          .to_return(status: 404, body: "{}")

        post "/api/contact_requests?slug=#{slug}", client_create_body, api_test_rack_env

        expect(last_response.status).to eq(404)
        expect(JSON.parse(last_response.body)).to match_json_expression({
          "errors" => [{ "title": "Failed to create contact request", "detail": nil }]
        })
      end

      it "handles non-JSON responses from NationBuilder" do
        stub_match_nb_person(nil)
        stub_request(:post, post_url).with(body: forwarded_create_person )
          .to_return(status: 200, body: "<html><body>Gateway Timeout</body></html>")

        post "/api/contact_requests?slug=#{slug}", client_create_body, api_test_rack_env

        expect(last_response.status).to eq(500)
        expect(JSON.parse(last_response.body)).to match_json_expression({
          "errors" => [{ "title": "Failed to create contact request" }]
        })
      end
    end
  end
end
