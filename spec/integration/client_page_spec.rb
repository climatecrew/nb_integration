require "support/rack_test_helper"

RSpec.describe "GET /app" do
  include RackTestHelper

  it "returns successfully" do
      get "/app"

      expect(last_response).to be_ok
  end

  it "returns an HTML page" do
      get "/app"

      expect(last_response.headers['Content-Type']).to eq('text/html')
  end
end
