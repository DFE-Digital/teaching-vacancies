class RemoveEndListingReasonAndCandidateHiredFromFromVacancies < ActiveRecord::Migration[6.1]
  def change
    remove_column :vacancies, :end_listing_reason, :integer
    remove_column :vacancies, :candidate_hired_from, :integer
  end
end
