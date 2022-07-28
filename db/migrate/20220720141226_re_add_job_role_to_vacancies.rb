class ReAddJobRoleToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :job_role, :integer
  end
end
