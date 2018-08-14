# frozen_string_literal: true

require 'json'

class ErrorPresenter
  def initialize(body: '')
    @body = body
  end

  attr_reader :body

  def transform
    transformed = JSON.parse(body)
    if transformed.has_key?('validation_errors')
      transformed['validation_errors'].map do |error|
        {
          'code' => transformed['code'],
          'detail' => error
        }
      end
    else
      [{
        'code' => transformed['code'],
        'detail' => transformed['message']
      }]
    end
  end
end
