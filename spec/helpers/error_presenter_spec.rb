# frozen_string_literal: true

RSpec.describe ErrorPresenter do
  it 'transforms an NB authorization failure message field into a detail field' do
    nb_body = <<~JSON
      {
        "code":"unauthorized",
        "message":"You are not authorized to access this content. Your access token may be missing. The resource owner also may not have a permission level sufficient to grant access."
      }
    JSON

    expected = {
      'errors' => [
        {
          'code' => 'unauthorized',
          'title' => nil,
          'detail' => 'You are not authorized to access this content. Your access token may be missing. The resource owner also may not have a permission level sufficient to grant access.'
        }
      ]
    }
    expect(described_class.new(nb_body).to_h).to eq(expected)
  end

  it 'if NB validation_errors present it transforms them into error items with titles' do
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

    expected = {
      'errors' => [
        {
          'code' => 'validation_failed',
          'title' => 'email is too short (minimum is 3 characters)',
          'detail' => nil
        }, {
          'code' => 'validation_failed',
          'title' => "email 'c' should look like an email address",
          'detail' => nil
        }
      ]
    }
    expect(described_class.new(nb_body).to_h).to match_array(expected)
  end
end
