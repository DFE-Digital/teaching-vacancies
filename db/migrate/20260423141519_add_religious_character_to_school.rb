class AddReligiousCharacterToSchool < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :religious_character, :string
    add_column :organisations, :number_of_pupils, :integer
    add_column :organisations, :school_capacity, :integer
  end
end
