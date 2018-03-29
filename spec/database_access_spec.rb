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

  describe "db_user" do
    before do
      @old_db_user = ENV['DB_USER']
      @old_user = ENV['DB_USER']
    end

    after do
      ENV['USER'] = @old_db_user
      ENV['DB_USER'] = @old_db_user
    end

    it "returns ENV['USER'] by default" do
      ENV['DB_USER'] = nil
      ENV['USER'] = 'mufasa'

      expect(DatabaseAccess::db_user).to eq('mufasa')
    end

    it "returns ENV['DB_USER'] if present" do
      ENV['DB_USER'] = 'simba'
      ENV['USER'] = 'mufasa'

      expect(DatabaseAccess::db_user).to eq('simba')
    end
  end

  describe "db_password" do
    before do
      @old_db_password = ENV['DB_PASSWORD']
    end

    after do
      ENV['DB_PASSWORD'] = @old_db_password
    end

    it "returns ENV['DB_PASSWORD'] if present" do
      ENV['DB_PASSWORD'] = 'secret'

      expect(DatabaseAccess::db_password).to eq('secret')
    end
  end

  describe "db_url" do
    before do
      @old_db_user = ENV['DB_USER']
      @old_db_password = ENV['DB_PASSWORD']
    end

    after do
      ENV['DB_USER'] = @old_db_user
      ENV['DB_PASSWORD'] = @old_db_password
    end

    it "returns a URL derived from environment" do
      ENV['DB_USER'] = 'user'
      ENV['DB_PASSWORD'] = 'password'
      host = 'localhost'
      port = '5432'
      db_name = 'db_name'

      expect(DatabaseAccess::db_url).to eq("postgres://user:password@#{host}:#{port}/#{db_name}")
    end
  end
end
