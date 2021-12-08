class AddContractDurationsToVacancies < ActiveRecord::Migration[6.1]
  def change
    rename_column :vacancies, :contract_type_duration, :fixed_term_contract_duration
    add_column :vacancies, :parental_leave_cover_contract_duration, :string
  end
end
