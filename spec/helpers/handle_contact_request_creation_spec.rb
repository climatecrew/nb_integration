require "models/account"

RSpec.describe HandleContactRequestCreation do
  let(:logger) { Logger.new('log/test.log') }
  let(:slug) { 'test_slug' }
  let(:access_token) { 'test_token' }
  let(:account) { Account.create(nb_slug: slug, nb_access_token: access_token) }
  let(:person_id) { 123 }
  let(:put_url) do
    "https://#{slug}.nationbuilder.com/api/v1/people/#{person_id}" \
    "?access_token=#{access_token}"
  end
  let(:post_url) do
    "https://#{slug}.nationbuilder.com/api/v1/people" \
    "?access_token=#{access_token}"
  end

  describe "makes API request to NationBuilder" do
    it "does not overwrite required fields in person payload" do
      payload = {
        'person' => {
          'id' => person_id,
          'first_name' => 'F',
          'last_name' => 'L',
          'email' => 'E'
        }
      }

      forwarded_payload = {
        'person' => {
          'tags' => ['Prep Week September 2018'],
          'parent_id' => AppConfiguration.app_point_person_id.to_i
        }
      }

      stub_request(:put, put_url).with(body: forwarded_payload)

      described_class.new(logger, account, payload).call

      expect(a_request(:put, put_url)
        .with(body: forwarded_payload))
        .to have_been_made.once
    end

    it "sends non-null optional fields from person payload" do
      payload = {
        'person' => {
          'id' => person_id,
          'first_name' => 'F',
          'last_name' => 'L',
          'email' => 'E',
          'phone' => '111-1111',
          'mobile' => '222-2222',
          'work_phone_number' => '333-3333'
        }
      }

      forwarded_payload = {
        'person' => {
          'tags' => ['Prep Week September 2018'],
          'parent_id' => AppConfiguration.app_point_person_id.to_i,
          'phone' => '111-1111',
          'mobile' => '222-2222',
          'work_phone_number' => '333-3333'
        }
      }

      stub_request(:put, put_url).with(body: forwarded_payload)

      described_class.new(logger, account, payload).call

      expect(a_request(:put, put_url)
        .with(body: forwarded_payload))
        .to have_been_made.once
    end

    it "removes null optional fields from person payload" do
      payload = {
        'person' => {
          'id' => person_id,
          'first_name' => 'F',
          'last_name' => 'L',
          'email' => 'E',
          'phone' => nil,
          'mobile' => nil,
          'work_phone_number' => nil
        }
      }

      forwarded_payload = {
        'person' => {
          'tags' => ['Prep Week September 2018'],
          'parent_id' => AppConfiguration.app_point_person_id.to_i
        }
      }

      stub_request(:put, put_url).with(body: forwarded_payload)

      described_class.new(logger, account, payload).call

      expect(a_request(:put, put_url)
        .with(body: forwarded_payload))
        .to have_been_made.once
    end
  end

  context "when person ID not given" do
    let(:email) { 'me@example.com' }
    let(:payload) do
      {
       'person' => {
         'first_name' => 'F',
         'last_name' => 'L',
         'email' => email
       }
     }
    end

    describe "attempts to match the person by email before creating" do
      it "sends an update if it can match the person" do
        person_response = {
          "person" => {
            "id" => person_id,
            "email" => email
          }
        }
        match_nb_person = MatchNBPerson.new(nil, nil, email)
        allow(MatchNBPerson).to receive(:new).and_return(match_nb_person)
        allow(match_nb_person).to receive(:call).and_return(person_response)

        forwarded_payload = {
          'person' => {
            'tags' => ['Prep Week September 2018'],
            'parent_id' => AppConfiguration.app_point_person_id.to_i
          }
        }
        stub_request(:put, put_url).with(body: forwarded_payload)

        described_class.new(logger, account, payload).call

        expect(a_request(:put, put_url)
          .with(body: forwarded_payload))
          .to have_been_made.once
      end

      it "sends a create if it cannot match the person" do
        match_nb_person = MatchNBPerson.new(nil, nil, email)
        allow(MatchNBPerson).to receive(:new).and_return(match_nb_person)
        allow(match_nb_person).to receive(:call).and_return(nil)

        forwarded_payload = {
          'person' => {
            'first_name' => 'F',
            'last_name' => 'L',
            'email' => email,
            'tags' => ['Prep Week September 2018'],
            'parent_id' => AppConfiguration.app_point_person_id.to_i
          }
        }
        stub_request(:post, post_url).with(body: forwarded_payload)

        described_class.new(logger, account, payload).call

        expect(a_request(:post, post_url)
          .with(body: forwarded_payload))
          .to have_been_made.once
      end
    end
  end
end
