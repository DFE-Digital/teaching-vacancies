class ChangeVacancyCounters < ActiveRecord::Migration[6.1]
  def change
    remove_columns :vacancies, :weekly_pageviews, :weekly_pageviews_updated_at, :total_pageviews_updated_at, :total_get_more_info_clicks_updated_at
    change_column_default :vacancies, :total_pageviews, 0
    change_column_default :vacancies, :total_get_more_info_clicks, 0
  end
end
