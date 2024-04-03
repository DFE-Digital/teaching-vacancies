class RemoveJobRoleFromVacancy < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :vacancies, :job_role, :integer }
  end
end
