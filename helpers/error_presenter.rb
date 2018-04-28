require "json"

class ErrorPresenter
  def initialize(body: "")
    @body = body
  end

  attr_reader :body

  def transform
    transformed = JSON.parse(body)
    transformed["detail"] = transformed.delete("message")
    transformed
  end
end
