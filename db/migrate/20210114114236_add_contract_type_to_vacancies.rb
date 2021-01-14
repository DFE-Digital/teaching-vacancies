class AddContractTypeToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :contract_type, :integer
    add_column :vacancies, :contract_type_duration, :string
  end
end
