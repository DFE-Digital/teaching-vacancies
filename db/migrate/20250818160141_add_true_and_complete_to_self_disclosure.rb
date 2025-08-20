class AddTrueAndCompleteToSelfDisclosure < ActiveRecord::Migration[7.2]
  def change
    add_column :self_disclosures, :true_and_complete_ciphertext, :string
    add_column :job_references, :not_provided_reason, :string
  end
end
