require "models/account"

RSpec.describe HandleContactRequestCreation do
  let(:logger) { Logger.new('log/test.log') }
  let(:slug) { 'test_slug' }
  let(:access_token) { 'test_token' }
  let(:account) { Account.create(nb_slug: slug, nb_access_token: access_token) }
  let(:post_url) do
    "https://#{slug}.nationbuilder.com/api/v1/people" \
    "?access_token=#{access_token}"
  end

  describe "makes API request to NationBuilder" do
    it "removes null items from person payload" do
      payload = {
        'person' => {
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
          'first_name' => 'F',
          'last_name' => 'L',
          'email' => 'E',
          'tags' => ['Prep Week September 2018'],
          'parent_id' => AppConfiguration.app_point_person_id.to_i
        }
      }

      stub_request(:post, post_url).with(body: forwarded_payload)

      described_class.new(logger, account, payload).call

      expect(a_request(:post, post_url)
        .with("body": forwarded_payload))
        .to have_been_made.once
    end
  end
end
