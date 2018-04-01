require "logger"
require File.expand_path("../../helpers/app_configuration.rb", __FILE__)

RSpec.describe AppConfiguration do
  let(:including_class) do
    Class.new do
      include AppConfiguration
    end
  end

  describe "nb_api_token" do
    it "returns ENV['NB_API_TOKEN']" do
      ENV['NB_API_TOKEN'] = 'abc'
      object = including_class.new

      expect(object.nb_api_token).to eq('abc')
    end
  end

  describe "nb_slug" do
    it "returns ENV['NB_SLUG']" do
      ENV['NB_SLUG'] = 'mynation'
      object = including_class.new

      expect(object.nb_slug).to eq('mynation')
    end
  end

  describe "nb_configuration_valid?" do
    it "returns true if API token and slug are present" do
      object = including_class.new

      ENV['NB_API_TOKEN'] = 'abc'
      ENV['NB_SLUG'] = 'mynation'

      expect(object.nb_configuration_valid?).to be_truthy
    end

    it "returns false if API Token missing" do
      object = including_class.new

      ENV['NB_API_TOKEN'] = nil
      ENV['NB_SLUG'] = 'mynation'

      expect(object.nb_configuration_valid?).to be_falsy
    end

    it "returns false if slug missing" do
      object = including_class.new

      ENV['NB_API_TOKEN'] = 'abc'
      ENV['NB_SLUG'] = nil

      expect(object.nb_configuration_valid?).to be_falsy
    end
  end

  describe "log_nb_configuration_error" do
    it "logs if ENV['NB_API_TOKEN'] unset" do
      logger = Logger.new($stderr)
      object = including_class.new

      ENV['NB_API_TOKEN'] = nil
      ENV['NB_SLUG'] = 'mynation'

      allow(logger).to receive(:warn).with("ENV['NB_API_TOKEN'] unset.")

      object.log_nb_configuration_error(logger)

      expect(logger).to have_received(:warn).with("ENV['NB_API_TOKEN'] unset.")
    end

    it "logs if ENV['NB_SLUG'] unset" do
      logger = Logger.new($stderr)
      object = including_class.new

      ENV['NB_API_TOKEN'] = 'abc'
      ENV['NB_SLUG'] = nil

      allow(logger).to receive(:warn).with("ENV['NB_SLUG'] unset.")

      object.log_nb_configuration_error(logger)

      expect(logger).to have_received(:warn).with("ENV['NB_SLUG'] unset.")
    end
  end

  describe "domain_name" do
    it "returns ENV['DOMAIN_NAME']" do
      ENV['DOMAIN_NAME'] = 'www.example.com'
      object = including_class.new

      expect(object.domain_name).to eq('www.example.com')
    end
  end

  describe "protocol" do
    it "defaults to https" do
      object = including_class.new

      ENV.delete('HTTP_PROTOCOL')

      expect(object.protocol).to eq('https')
    end

    it "returns ENV['HTTP_PROTOCOL'] if present" do
      object = including_class.new

      ENV['HTTP_PROTOCOL'] = 'http'

      expect(object.protocol).to eq('http')
    end
  end

  describe "app_base_url" do
    it "returns a URL configured with protocol and domain" do
      object = including_class.new
      ENV['HTTP_PROTOCOL'] = 'http'
      ENV['DOMAIN_NAME'] = 'api.test.gov'

      expect(object.app_base_url).to eq('http://api.test.gov')
    end
  end

  describe "app_client_id" do
    it "returns ENV['NB_CLIENT_ID']" do
      object = including_class.new

      ENV['NB_CLIENT_ID'] = '29edc'

      expect(object.app_client_id).to eq('29edc')
    end
  end

  describe "app_client_secret" do
    it "returns ENV['NB_CLIENT_SECRET']" do
      object = including_class.new

      ENV['NB_CLIENT_SECRET'] = 'dd74e'

      expect(object.app_client_secret).to eq('dd74e')
    end
  end
end
