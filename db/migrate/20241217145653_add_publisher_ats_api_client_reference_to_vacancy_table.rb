class AddPublisherAtsApiClientReferenceToVacancyTable < ActiveRecord::Migration[7.2]
  def change
    add_reference :vacancies, :publisher_ats_api_client, foreign_key: true, index: true, type: :uuid
  end
end
