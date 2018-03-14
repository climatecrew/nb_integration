class PathProvider
  def initialize(slug:, api_token:)
    @slug = slug
    @api_token = api_token
  end

  attr_reader :slug, :api_token

  def index(resource)
    "#{base_url}/sites/#{slug}/pages/#{resource}?#{access_token}"
  end

  def create(resource)
    if resource == :events
      "#{base_url}/sites/#{slug}/pages/#{resource}?#{access_token}"
    else
      "#{base_url}/#{resource}?#{access_token}"
    end
  end

  def delete(resource, id)
    if resource == :events
      "#{base_url}/sites/#{slug}/pages/#{resource}/#{id}?#{access_token}"
    else
      "#{base_url}/#{resource}/#{id}?#{access_token}"
    end
  end

  def update(resource, id)
    if resource == :events
    "#{base_url}/sites/#{slug}/pages/#{resource}/#{id}?#{access_token}"
    else
      "#{base_url}/#{resource}/#{id}?#{access_token}"
    end
  end

  def match(resource, parameters)
    encoded_parameters = parameters.each_with_object([]) do |(key, val), list|
      list << "#{CGI::escape(key.to_s)}=#{CGI::escape(val.to_s)}"
    end
    query_string = encoded_parameters.join("&")
    "#{base_url}/#{resource}/match?#{query_string}&#{access_token}"
  end

  private

  def base_url
    "https://#{slug}.nationbuilder.com/api/v1"
  end

  def access_token
    "access_token=#{api_token}"
  end
end
