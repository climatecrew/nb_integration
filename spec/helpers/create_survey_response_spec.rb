RSpec.describe CreateSurveyResponse do
  let(:logger) { Logger.new('log/test.log') }
  let(:slug) { 'test_slug' }
  let(:access_token) { 'test_token' }
  let(:person_id) { 33 }
  let(:survey_id) { 7 }
  let(:question_id) { 4 }
  let(:response_text) { "I would like to organize a concert." }
  let(:path_provider) { PathProvider.new(slug: slug, api_token: access_token) }
  let(:url) do
    "https://#{slug}.nationbuilder.com/api/v1/survey_responses" \
      "?access_token=#{access_token}"
  end

  before do
    ENV['NB_EVENT_PLANNING_SURVEY_ID'] = survey_id.to_s
    ENV['NB_EVENT_PLANNING_SURVEY_COMMENTS_QUESTION_ID'] = question_id.to_s
  end

  it "makes an API request to NationBuilder" do
    expected_body =
      {
        "survey_response": {
          "survey_id": survey_id,
          "person_id": person_id,
          "is_private": true,
          "question_responses": [{
            "question_id": question_id,
            "response": response_text
          }]
        }
    }
    stub_request(:post, url).with(body: expected_body).to_return(body: "{}")

    described_class.new(logger, path_provider, person_id, response_text).call

    expect(a_request(:post, url)
      .with(body: JSON.generate(expected_body)))
      .to have_been_made.once
  end
end
