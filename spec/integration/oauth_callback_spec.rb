RSpec.describe "GET /oauth/callback" do
  let(:host) { RSpec.configuration.integration_test_server }
  it "returns 200" do
    response = Faraday.get "#{host}/oauth/callback"
    expect(response.status).to eq(200)
  end
end
