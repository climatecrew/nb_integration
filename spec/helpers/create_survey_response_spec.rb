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

  it "makes an API request to NationBuilder" do
    stub_request(:post, url).to_return(body: "{}")
    described_class.new(logger, path_provider, person_id, response_text).call
    expect(a_request(:post, url)
            .with do |req| req.body == "abc"
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
                  end
          ).to have_been_made.once
  end
end
