RSpec.describe MatchNBPerson do
  let(:logger) { Logger.new('log/test.log') }
  let(:slug) { 'test_slug' }
  let(:access_token) { 'test_token' }
  let(:email) { 'person@example.com' }
  let(:path_provider) { PathProvider.new(slug: slug, api_token: access_token) }
  let(:url) do
    "https://#{slug}.nationbuilder.com/api/v1/people/match" \
    "?access_token=#{access_token}" \
    "&email=#{email}"
  end

  it "makes an API request to NationBuilder" do
    stub_request(:get, url).to_return(body: "{}")
    described_class.new(logger, path_provider, email).call
    expect(a_request(:get, url)).to have_been_made.once
  end

  it "returns nil if the response is unsuccessful" do
    stub_request(:get, url)
      .to_return(status: 400,
                 body: JSON.generate({
                   "code": "no_matches",
                   "message": "No people matched the given criteria."
                 })
                )
    expect(described_class.new(logger, path_provider, email).call).to be_nil
  end

  it "returns nil if the response is not JSON" do
    stub_request(:get, url)
      .to_return(body: "<html><body>Service Unavailable</body></html>")
    expect(described_class.new(logger, path_provider, email).call).to be_nil
  end

  it "returns a person API hash when response is successful" do
    expected_hash = {
      "person" => {
        "id" => 2,
        "birthdate" => nil,
        "email" => "person@example.com"
      }
    }
    stub_request(:get, url)
      .to_return(status: 200, body: JSON.generate(expected_hash))
    expect(described_class.new(logger, path_provider, email).call).to eq(expected_hash)
  end
end
