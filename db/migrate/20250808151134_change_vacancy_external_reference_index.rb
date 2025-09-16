class ChangeVacancyExternalReferenceIndex < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :vacancies,
              %i[external_reference publisher_ats_api_client_id],
              unique: true,
              name: "index_kept_unique_vacancies_on_external_ref_and_client_id",
              where: "discarded_at IS NULL",
              algorithm: :concurrently

    remove_index :vacancies,
                 %i[external_reference publisher_ats_api_client_id],
                 unique: true,
                 name: "index_vacancies_on_external_ref_and_publisher_ats_client_id",
                 algorithm: :concurrently
  end
end
