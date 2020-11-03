class ConvertNqtJobRoleToSuitableForNqtOnVacancies < ActiveRecord::Migration[5.2]
  def change
    Vacancy.where("'Suitable for NQTs' = ANY (job_roles)").update_all(suitable_for_nqt: "yes")
  end
end
