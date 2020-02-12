class AddKeyInfoToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :status, :string
    add_column :schools, :trust_name, :string
    add_column :schools, :number_of_pupils, :integer
    add_column :schools, :head_title, :string
    add_column :schools, :head_first_name, :string
    add_column :schools, :head_last_name, :string
    add_column :schools, :religious_character, :string
    add_column :schools, :rsc_region, :string
    add_column :schools, :telephone, :string
    add_column :schools, :open_date, :date
    add_column :schools, :close_date, :date
    add_column :schools, :last_ofsted_inspection_date, :date
    add_column :schools, :oftsed_rating, :string
  end
end
