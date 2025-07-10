class AddDetailsToJobReference < ActiveRecord::Migration[7.2]
  def change
    add_column :job_references, :under_investigation_details_ciphertext, :string
    add_column :job_references, :warning_details_ciphertext, :string
    add_column :job_references, :unable_to_undertake_reason_ciphertext, :string

    # an encrypted date
    add_column :job_references, :employment_end_date_ciphertext, :string
  end
end
