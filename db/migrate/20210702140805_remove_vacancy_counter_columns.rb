class RemoveVacancyCounterColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :vacancies, :total_pageviews
    remove_column :vacancies, :total_get_more_info_clicks
  end
end
