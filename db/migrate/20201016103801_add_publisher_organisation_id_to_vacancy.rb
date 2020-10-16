class AddPublisherOrganisationIdToVacancy < ActiveRecord::Migration[6.0]
  def change
    add_reference :vacancies, :publisher_organisation, foreign_key: { to_table: :organisations }, type: :uuid
  end
end
