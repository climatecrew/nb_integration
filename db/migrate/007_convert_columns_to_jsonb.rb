# frozen_string_literal: true

Sequel.migration do
  up do
    run 'ALTER TABLE contact_requests ALTER COLUMN nb_person SET DATA TYPE jsonb USING nb_person::jsonb'
    run 'ALTER TABLE events ALTER COLUMN nb_event SET DATA TYPE jsonb USING nb_event::jsonb'
  end

  down do
    run 'ALTER TABLE contact_requests ALTER COLUMN nb_person SET DATA TYPE json USING nb_person::json'
    run 'ALTER TABLE events ALTER COLUMN nb_event SET DATA TYPE json USING nb_event::json'
  end
end
