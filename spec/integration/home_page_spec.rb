require "support/rack_test_helper"

RSpec.describe "GET /" do
  include RackTestHelper

  it "returns successfully" do
      get "/"

      expect(last_response).to be_ok
  end

  it "returns an HTML page" do
      get "/"

      expect(last_response.headers['Content-Type']).to eq('text/html')
  end
end
