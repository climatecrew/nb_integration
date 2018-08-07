# frozen_string_literal: true

RSpec.describe CreateSurveyResponse do
  let(:logger) { Logger.new('log/test.log') }
  let(:slug) { 'test_slug' }
  let(:access_token) { 'test_token' }
  let(:person_id) { 33 }
  let(:response_text) { 'I would like to organize a concert.' }
  let(:contact_request) do
    ContactRequest.create(nb_slug: slug,
                          nb_user_id: person_id,
                          notes: response_text)
  end
  let(:survey_id) { 7 }
  let(:question_id) { 4 }
  let(:path_provider) { PathProvider.new(slug: slug, api_token: access_token) }
  let(:url) do
    "https://#{slug}.nationbuilder.com/api/v1/survey_responses" \
      "?access_token=#{access_token}"
  end

  before do
    ENV['NB_EVENT_PLANNING_SURVEY_ID'] = survey_id.to_s
    ENV['NB_EVENT_PLANNING_SURVEY_COMMENTS_QUESTION_ID'] = question_id.to_s
  end

  it 'makes an API request to NationBuilder' do
    expected_body = {
      'survey_response' => {
        'survey_id' => survey_id,
        'person_id' => person_id,
        'is_private' => true,
        'question_responses' => [{
          'question_id' => question_id,
          'response' => response_text
        }]
      }
    }
    stub_request(:post, url).with(body: expected_body)

    described_class.new(logger, path_provider, contact_request).call

    expect(a_request(:post, url)
      .with(body: JSON.generate(expected_body)))
      .to have_been_made.once
  end

  it 'writes the survey response to the DB when successful' do
    expected_response_body = {
      'survey_response' => {
        'id' => 5,
        'updated_at' => '2018-08-04T17:41:50-04:00',
        'created_at' => '2018-08-04T17:41:50-04:00',
        'survey_id' => survey_id,
        'person_id' => person_id,
        'is_private' => true,
        'question_responses' => [{
          'id' => 1,
          'question_id' => question_id,
          'response' => response_text
        }]
      }
    }
    stub_request(:post, url).to_return(body: JSON.generate(expected_response_body))

    described_class.new(logger, path_provider, contact_request).call

    expect(JSON.parse(contact_request.refresh.nb_survey_response)).to eq(expected_response_body)
  end

  it 'does not raise an error if the survey response creation fails' do
    stub_request(:post, url).to_return(status: 503, body: '<h1>Service Unavailable</h1>')
    expect do
      described_class.new(logger, path_provider, contact_request).call
    end.not_to raise_error

    expect(contact_request.refresh.nb_survey_response).to be_nil
  end

  it 'does not raise an error if recording the survey response fails' do
    stub_request(:post, url).to_return(body: '{}')
    allow(contact_request).to receive(:update).and_raise('Nothing gold can stay')

    expect do
      described_class.new(logger, path_provider, contact_request).call
    end.not_to raise_error
  end
end
