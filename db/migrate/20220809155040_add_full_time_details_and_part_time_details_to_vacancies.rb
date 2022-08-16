class AddFullTimeDetailsAndPartTimeDetailsToVacancies < ActiveRecord::Migration[7.0]
  def change
    add_column :vacancies, :full_time_details, :text
    add_column :vacancies, :part_time_details, :text
  end
end
