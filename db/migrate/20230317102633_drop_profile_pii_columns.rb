class DropProfilePiiColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :personal_details, :first_name, :string
    remove_column :personal_details, :last_name, :string
    remove_column :personal_details, :phone_number, :string
  end
end
