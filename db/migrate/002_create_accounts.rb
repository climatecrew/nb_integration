# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:accounts) do
      column :id, 'uuid', default: Sequel::LiteralString.new('uuid_generate_v4()'), null: false
      column :created_at, 'timestamp with time zone'
      column :updated_at, 'timestamp with time zone'
      column :nb_slug, 'text'
      column :nb_access_token, 'text'

      primary_key [:id]
    end
  end
end
