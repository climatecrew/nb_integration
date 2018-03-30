require File.expand_path("../../helpers/database_access.rb", __FILE__)

RSpec.describe DatabaseAccess do
  let(:including_class) do
    Class.new do
      include DatabaseAccess
    end
  end

  it "provides a DB constant" do
    expect(described_class::DB).to be
  end

  describe ".connect_options" do
    before do
      @old_db_url = ENV['DB_URL']
    end

    after do
      ENV['DB_URL'] = @old_db_url
    end

    it "reads from the environment" do
      db_url = 'postgres://user:password@localhost/nb_integration_test'
      ENV['DB_URL'] = db_url
      expect(DatabaseAccess.connect_options).to eq(db_url)
    end
  end
end
