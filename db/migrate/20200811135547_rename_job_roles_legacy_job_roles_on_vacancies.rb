class RenameJobRolesLegacyJobRolesOnVacancies < ActiveRecord::Migration[5.2]
  def change
    rename_column :vacancies, :job_roles, :legacy_job_roles
  end
end
