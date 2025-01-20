class AddPublisherAtsApiClientReferenceToVacancyTable < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    add_column :vacancies, :publisher_ats_api_client_id, :uuid
    add_index :vacancies, :publisher_ats_api_client_id, algorithm: :concurrently
    add_foreign_key :vacancies, :publisher_ats_api_clients, column: :publisher_ats_api_client_id, validate: false
    validate_foreign_key :vacancies, :publisher_ats_api_clients
  end

  def down
    remove_foreign_key :vacancies, :publisher_ats_api_clients
    remove_index :vacancies, :publisher_ats_api_client_id, algorithm: :concurrently
    remove_column :vacancies, :publisher_ats_api_client_id
  end
end
