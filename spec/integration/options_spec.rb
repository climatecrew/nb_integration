require "support/rack_test_helper"

RSpec.describe "OPTIONS /api" do
  include RackTestHelper

  it "sends back an Allow header" do
    options "/api", {}, test_rack_env

    expect(last_response.status).to eq(200)
    expect(last_response.headers["Allow"]).to eq("GET, HEAD, POST, PUT")
    expect(last_response.headers["Access-Control-Allow-Origin"]).to eq("*")
    expect(last_response.headers["Access-Control-Allow-Headers"])
      .to eq("Accept, Accept-Language, Content-Language, Content-Type")
  end
end

