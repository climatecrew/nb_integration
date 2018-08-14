# frozen_string_literal: true

RSpec.describe ErrorPresenter do
  it 'transforms an NB message field into a detail field' do
    nb_body = <<~JSON
      {
        "code":"unauthorized",
        "message":"You are not authorized to access this content. Your access token may be missing. The resource owner also may not have a permission level sufficient to grant access."
      }
    JSON

    expected = [{
      'code' => 'unauthorized',
      'detail' => 'You are not authorized to access this content. Your access token may be missing. The resource owner also may not have a permission level sufficient to grant access.'
    }]
    expect(described_class.new(body: nb_body).transform).to eq(expected)
  end

  it "if NB validation_errors present it transforms them into error items with details" do
    nb_body = <<~JSON
    {
      "code":"validation_failed",
      "message":"Validation Failed.",
      "validation_errors":[
        "email is too short (minimum is 3 characters)",
        "email 'c' should look like an email address"
      ]
    }
    JSON

    expected = [{
      'code' => 'validation_failed',
      'detail' => 'email is too short (minimum is 3 characters)'
    }, {
      'code' => 'validation_failed',
      'detail' => "email 'c' should look like an email address"
    }]
    expect(described_class.new(body: nb_body).transform).to match_array(expected)
  end
end
