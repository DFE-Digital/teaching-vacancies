class RenameJobSummaryToJobAdvertOnVacancies < ActiveRecord::Migration[6.1]
  def change
    rename_column :vacancies, :job_summary, :job_advert
  end
end
