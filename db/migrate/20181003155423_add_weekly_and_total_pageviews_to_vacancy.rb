class AddWeeklyAndTotalPageviewsToVacancy < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :weekly_pageviews, :integer
    add_column :vacancies, :total_pageviews, :integer
    add_column :vacancies, :weekly_pageviews_updated_at, :datetime
    add_column :vacancies, :total_pageviews_updated_at, :datetime
  end
end
