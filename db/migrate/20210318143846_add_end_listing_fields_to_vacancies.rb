class AddEndListingFieldsToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :end_listing_reason, :integer
    add_column :vacancies, :candidate_hired_from, :integer
  end
end
