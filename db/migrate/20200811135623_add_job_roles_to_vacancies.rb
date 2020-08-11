class AddJobRolesToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :job_roles, :integer, array: true
  end
end
