class ConvertNqtJobRoleToSuitableForNqtOnVacancies < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.connection.execute(
    "UPDATE vacancies SET suitable_for_nqt = 'yes' WHERE 'Suitable for NQTs' = ANY(job_roles)"
    )
  end
end
