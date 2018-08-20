# frozen_string_literal: true

require 'json'

class ErrorPresenter
  def initialize(body = '{}')
    @body = if body.is_a?(Hash)
              body
            else
              JSON.parse(body.to_s)
            end
    @body = transform(@body)
  end

  def to_h
    { 'errors' => @body }
  end

  private

  def transform(body)
    if body.key?('validation_errors')
      validation_errors = body['validation_errors']
      validation_errors.map do |error|
        {
          'code' => body['code'],
          'title' => error,
          'detail' => nil
        }
      end
    elsif body.key?('message')
      [{
        'code' => body['code'],
        'title' => nil,
        'detail' => body['message']
      }]
    else
      [body]
    end
  end
end
