class ChangeJobDescriptionToJobSummary < ActiveRecord::Migration[5.2]
  def change
    rename_column :vacancies, :job_description, :job_summary
  end
end
