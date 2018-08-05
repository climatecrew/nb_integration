Sequel.migration do
  change do
    add_column :contact_requests, :nb_survey_response, "json"
  end
end
