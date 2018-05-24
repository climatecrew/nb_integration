require "logger"
require File.expand_path("../../helpers/app_configuration.rb", __FILE__)

RSpec.describe AppConfiguration do
  describe "nb_configuration_valid?" do
    it "returns true if NB_CLIENT_ID and NB_CLIENT_SECRET are present" do
      ENV['NB_CLIENT_ID'] = 'abc'
      ENV['NB_CLIENT_SECRET'] = 'def'

      expect(described_class.nb_configuration_valid?).to be_truthy
    end

    it "returns false if API Token missing" do
      ENV['NB_CLIENT_ID'] = nil
      ENV['NB_CLIENT_SECRET'] = 'def'

      expect(described_class.nb_configuration_valid?).to be_falsy
    end

    it "returns false if slug missing" do
      ENV['NB_CLIENT_ID'] = 'abc'
      ENV['NB_CLIENT_SECRET'] = nil

      expect(described_class.nb_configuration_valid?).to be_falsy
    end
  end

  describe "log_nb_configuration_error" do
    it "logs if ENV['NB_CLIENT_ID'] unset" do
      logger = Logger.new($stderr)

      ENV['NB_CLIENT_ID'] = nil
      ENV['NB_CLIENT_SECRET'] = 'def'

      allow(logger).to receive(:warn).with("ENV['NB_CLIENT_ID'] unset.")

      described_class.log_nb_configuration_error(logger)

      expect(logger).to have_received(:warn).with("ENV['NB_CLIENT_ID'] unset.")
    end

    it "logs if ENV['NB_CLIENT_SECRET'] unset" do
      logger = Logger.new($stderr)

      ENV['NB_CLIENT_ID'] = 'abc'
      ENV['NB_CLIENT_SECRET'] = nil

      allow(logger).to receive(:warn).with("ENV['NB_CLIENT_SECRET'] unset.")

      described_class.log_nb_configuration_error(logger)

      expect(logger).to have_received(:warn).with("ENV['NB_CLIENT_SECRET'] unset.")
    end
  end

  describe "domain_name" do
    it "returns ENV['DOMAIN_NAME']" do
      ENV['DOMAIN_NAME'] = 'www.example.com'
      expect(described_class.domain_name).to eq('www.example.com')
    end
  end

  describe "protocol" do
    it "defaults to https" do
      ENV.delete('HTTP_PROTOCOL')

      expect(described_class.protocol).to eq('https')
    end

    it "returns ENV['HTTP_PROTOCOL'] if present" do
      ENV['HTTP_PROTOCOL'] = 'http'

      expect(described_class.protocol).to eq('http')
    end
  end

  describe "app_base_url" do
    it "returns a URL configured with protocol and domain" do
      ENV['HTTP_PROTOCOL'] = 'http'
      ENV['DOMAIN_NAME'] = 'api.test.gov'

      expect(described_class.app_base_url).to eq('http://api.test.gov')
    end
  end

  describe "app_client_id" do
    it "returns ENV['NB_CLIENT_ID']" do
      ENV['NB_CLIENT_ID'] = '29edc'

      expect(described_class.app_client_id).to eq('29edc')
    end
  end

  describe "app_client_secret" do
    it "returns ENV['NB_CLIENT_SECRET']" do
      ENV['NB_CLIENT_SECRET'] = 'dd74e'

      expect(described_class.app_client_secret).to eq('dd74e')
    end
  end
end
