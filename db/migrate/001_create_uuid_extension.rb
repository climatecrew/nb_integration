# frozen_string_literal: true

Sequel.migration do
  up do
    run('CREATE EXTENSION "uuid-ossp"')
  end

  down do
    run('DROP EXTENSION "uuid-ossp"')
  end
end
