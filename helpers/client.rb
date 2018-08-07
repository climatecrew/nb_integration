# frozen_string_literal: true

require 'faraday'

module Client
  module_function

  def index(path_provider:, resource:)
    conn = Faraday.new(url: path_provider.index(resource))
    conn.get do |req|
      req = set_headers(req)
    end
  end

  module_function

  def create(path_provider:, resource:, payload: {})
    conn = Faraday.new(url: path_provider.create(resource))
    conn.post do |req|
      req = set_headers(req)
      req.body = JSON.generate(payload)
    end
  end

  module_function

  def delete(path_provider:, resource:, id:)
    conn = Faraday.new(url: path_provider.delete(resource, id))
    conn.delete do |req|
      req = set_headers(req)
    end
  end

  module_function

  def update(path_provider:, resource:, id:, payload:)
    conn = Faraday.new(url: path_provider.update(resource, id))
    conn.put do |req|
      req = set_headers(req)
      req.body = JSON.generate(payload)
    end
  end

  module_function

  def match(path_provider:, resource:, parameters:)
    conn = Faraday.new(url: path_provider.match(resource, parameters))
    conn.get do |req|
      req = set_headers(req)
    end
  end

  def set_headers(req)
    req.headers['Accept'] = 'application/json'
    req.headers['Content-Type'] = 'application/json'
    req
  end
end
