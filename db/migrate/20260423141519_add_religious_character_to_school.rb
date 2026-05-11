class AddReligiousCharacterToSchool < ActiveRecord::Migration[8.0]
  def change
    add_column :organisations, :religious_character, :string, null: false, default: "None"
  end
end
