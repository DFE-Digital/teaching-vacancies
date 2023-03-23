class AddPiiCiphertextToPersonalDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :personal_details, :first_name_ciphertext, :text
    add_column :personal_details, :last_name_ciphertext, :text
    add_column :personal_details, :phone_number_ciphertext, :text
  end
end
