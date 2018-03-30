Sequel.migration do
  change do
    create_table(:accounts) do
      column :id, "uuid", :default=>Sequel::LiteralString.new("uuid_generate_v4()"), :null=>false
      column :nb_slug, "text"
      column :nb_access_token, "text"

      primary_key [:id]
    end
  end
end
