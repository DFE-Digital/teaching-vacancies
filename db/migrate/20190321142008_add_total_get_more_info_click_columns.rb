class AddTotalGetMoreInfoClickColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :vacancies, :total_get_more_info_clicks, :integer
    add_column :vacancies, :total_get_more_info_clicks_updated_at, :datetime
  end
end
