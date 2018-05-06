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
end
