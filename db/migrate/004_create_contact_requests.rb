# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:contact_requests) do
      column :id, 'uuid', default: Sequel::LiteralString.new('uuid_generate_v4()'), null: false
      column :created_at, 'timestamp with time zone'
      column :updated_at, 'timestamp with time zone'
      column :nb_slug, 'text'
      column :nb_user_id, 'bigint'
      column :nb_user_email, 'text'
      column :nb_person, 'json'

      primary_key [:id]
    end
  end
end
