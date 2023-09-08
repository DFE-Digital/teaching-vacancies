class AddVisaSponsorshipAvailableToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :visa_sponsorship_available, :boolean
  end
end
