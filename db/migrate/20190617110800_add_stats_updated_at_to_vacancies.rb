class AddStatsUpdatedAtToVacancies < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :stats_updated_at, :datetime
  end
end
