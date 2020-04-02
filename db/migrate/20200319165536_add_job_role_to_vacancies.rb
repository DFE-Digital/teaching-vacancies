class AddJobRoleToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :job_roles, :string, array: true
  end
end
