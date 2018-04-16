Sequel.migration do
  change do
    create_table(:events) do
      column :id, "uuid", :default=>Sequel::LiteralString.new("uuid_generate_v4()"), :null=>false
      column :created_at, "timestamp with time zone"
      column :updated_at, "timestamp with time zone"
      column :nb_slug, "text"
      column :author_nb_id, "bigint"
      column :author_email, "text"
      column :contact_email, "text"
      column :nb_event, "json"

      primary_key [:id]
    end
  end
end
