# frozen_string_literal: true

RSpec.describe ErrorPresenter do
  it 'transforms an NB message field into a detail field' do
    nb_body = <<~JSON
      {
        "code":"unauthorized",
        "message":"You are not authorized to access this content. Your access token may be missing. The resource owner also may not have a permission level sufficient to grant access."
      }
    JSON

    expected = {
      'code' => 'unauthorized',
      'detail' => 'You are not authorized to access this content. Your access token may be missing. The resource owner also may not have a permission level sufficient to grant access.'
    }
    expect(described_class.new(body: nb_body).transform).to eq(expected)
  end
end
