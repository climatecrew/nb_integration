require 'sequel'
require File.expand_path("../../helpers/database_access.rb", __FILE__)

RSpec.describe DatabaseAccess do
  let(:including_class) do
    Class.new do
      include DatabaseAccess
    end
  end

  it "sets DB to a connection" do
    connection = Sequel.connect(ENV['DATABASE_URL'])
    expect(described_class::DB.opts[:uri]).to eq(connection.opts[:uri])
  end

  it "makes the DB constant available to including class" do
    expect(including_class::DB).to eq(described_class::DB)
  end

  describe ".connect_options" do
    before do
      @old_db_url = ENV['DATABASE_URL']
    end

    after do
      ENV['DATABASE_URL'] = @old_db_url
    end

    it "reads from the environment" do
      db_url = 'postgres://user:password@localhost/nb_integration_test'
      ENV['DATABASE_URL'] = db_url
      expect(DatabaseAccess.connect_options).to eq(db_url)
    end
  end

  describe ".attempt" do
    it "rescues Sequel::DatabaseDisconnectError" do
      should_raise = true
      expect do
        described_class.attempt(wait_time: 0.01, logger: Logger.new('log/test.log')) do
          if should_raise
            should_raise = false
            raise Sequel::DatabaseDisconnectError
          end
        end
      end.not_to raise_error
    end

    it "rescues Sequel::DatabaseConnectionError" do
      should_raise = true
      expect do
        described_class.attempt(wait_time: 0.01, logger: Logger.new('log/test.log')) do
          if should_raise
            should_raise = false
            raise Sequel::DatabaseConnectionError
          end
        end
      end.not_to raise_error
    end

    it "passes other errors through" do
      should_raise = true
      expect do
        described_class.attempt(wait_time: 0.01, logger: Logger.new('log/test.log')) do
          if should_raise
            should_raise = false
            raise RuntimeError.new("Some other error")
          end
        end
      end.to raise_error(RuntimeError, /Some other error/)
    end

    it "re-raises rescued errors if it cannot succeed after retrying" do
      expect do
        described_class.attempt(wait_time: 0.01, logger: Logger.new('log/test.log')) do
          raise Sequel::DatabaseConnectionError
        end
      end.to raise_error(Sequel::DatabaseConnectionError)
    end

    it "attempts 3 times by default" do
      tries = 0
      expect do
        described_class.attempt(wait_time: 0.01, logger: Logger.new('log/test.log')) do
          tries += 1
          raise Sequel::DatabaseConnectionError
        end
      end.to raise_error(Sequel::DatabaseConnectionError)

      expect(tries).to eq(3)
    end

    it "attempts N times if specified" do
      tries = 0
      expect do
        described_class.attempt(wait_time: 0.01, max_attempts: 1, logger: Logger.new('log/test.log')) do
          tries += 1
          raise Sequel::DatabaseConnectionError
        end
      end.to raise_error(Sequel::DatabaseConnectionError)

      expect(tries).to eq(1)
    end

    it "logs the operation tag if given" do
      operation = "wassup"
      max_attempts = 1
      wait_time = 0.01
      logger = Logger.new('log/test.log')

      allow(logger).to receive(:warn)

      expect do
        described_class.attempt(wait_time: wait_time, logger: logger, max_attempts: max_attempts, operation: operation) do
          raise Sequel::DatabaseConnectionError
        end
      end.to raise_error(Sequel::DatabaseConnectionError)

      expect(logger)
        .to have_received(:warn)
        .with("#{operation} still unsuccessful after #{max_attempts} attempts. Giving up.")
    end
  end
end
