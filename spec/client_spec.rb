require File.expand_path("../../helpers/client.rb", __FILE__)

RSpec.describe Client do
  let(:resource) { :test_resource }
  let(:path_provider_klass) do
    Class.new do
      def initialize(path)
        @path = path
      end

      def index(resource)
        @path
      end

      def create(resource)
        @path
      end

      def delete(resource, id)
        @path
      end

      def update(resource, id)
        @path
      end

      def match(resource, parameters)
        @path
      end
    end
  end

  describe ".index" do
    let(:index_path) { "https://www.example.com/tests" }

    it "takes a path provider and a resource" do
      stub_request(:get, index_path)

      path_provider = path_provider_klass.new(index_path)
      Client.index(path_provider: path_provider, resource: resource)

      expect(a_request(:get, index_path).with(
        headers: {
          "Accept" => "application/json"
        })).to have_been_made.once
    end
  end

  describe ".create" do
    let(:create_path) { "https://www.example.com/tests" }

    it "takes a path provider and a resource" do
      stub_request(:post, create_path)

      path_provider = path_provider_klass.new(create_path)
      Client.create(path_provider: path_provider, resource: resource)

      expect(a_request(:post, create_path)).to have_been_made.once
    end

    it "defaults payload to {}" do
      stub_request(:post, create_path)

      path_provider = path_provider_klass.new(create_path)
      Client.create(path_provider: path_provider, resource: resource)

      expect(a_request(:post, create_path).with(body: {})).to have_been_made.once
    end

    it "accepts a payload" do
      stub_request(:post, create_path)

      expected_payload = {
        "key" => "value"
      }
      path_provider = path_provider_klass.new(create_path)
      Client.create(path_provider: path_provider,
                             resource: resource,
                             payload: expected_payload)

      expect(a_request(:post, create_path).with(
        body: JSON.generate(expected_payload),
        headers: {
          "Accept" => "application/json",
          "Content-Type" => "application/json"
        }
      )).to have_been_made.once
    end
  end

  describe ".delete" do
    let(:id) { 123 }
    let(:delete_path) { "https://www.example.com/tests/#{id}" }

    it "takes a path provider, resource, and id" do
      stub_request(:delete, delete_path)

      path_provider = path_provider_klass.new(delete_path)
      Client.delete(path_provider: path_provider, resource: resource, id: id)

      expect(a_request(:delete, delete_path).with(
        headers: {
          "Accept" => "application/json"
        })).to have_been_made.once
    end
  end

  describe ".update" do
    let(:id) { 123 }
    let(:update_path) { "https://www.example.com/tests/#{id}" }

    it "takes a path provider, resource, id, and payload" do
      stub_request(:put, update_path)

      path_provider = path_provider_klass.new(update_path)
      payload = {
        key: :value
      }
      Client.update(path_provider: path_provider,
                             resource: resource,
                             id: id,
                             payload: payload)

      expect(a_request(:put, update_path).with(
        headers: {
          "Accept" => "application/json",
          "Content-Type" => "application/json"
        }
      )).to have_been_made.once
    end
  end

  describe ".match" do
    let(:parameters) { { email: 'dog@canines.org', city: 'Dog Town' } }
    let(:match_path) { "https://www.example.com/tests/match?email=dog%40canines.org&city=Dog+Town" }

    it "takes a path provider, resource, id, and payload" do
      stub_request(:get, match_path)

      path_provider = path_provider_klass.new(match_path)
      Client.match(path_provider: path_provider,
                             resource: resource,
                             parameters: parameters)
      expect(a_request(:get, match_path).with(
        headers: {
          "Accept" => "application/json",
          "Content-Type" => "application/json"
        }
      )).to have_been_made.once
    end
  end
end
