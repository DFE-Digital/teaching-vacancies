class AddTrueAndCompleteToSelfDisclosure < ActiveRecord::Migration[7.2]
  def change
    add_column :self_disclosures, :true_and_complete_ciphertext, :string
  end
end
