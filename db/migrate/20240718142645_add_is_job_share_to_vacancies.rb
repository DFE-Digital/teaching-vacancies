class AddIsJobShareToVacancies < ActiveRecord::Migration[7.1]
  def change
    add_column :vacancies, :is_job_share, :boolean
  end
end
