class AddJobAddressToVacancies < ActiveRecord::Migration[8.0]
  def change
    add_column :vacancies, :job_address, :string
  end
end
