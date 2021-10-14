class RemoveLegacyJobRolesFromVacancies < ActiveRecord::Migration[6.1]
  def change
    remove_column :vacancies, :legacy_job_roles, :string
  end
end
