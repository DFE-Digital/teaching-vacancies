class AddLockboxCiphertextColumnsAndBlindIndexColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :account_requests, :email_ciphertext, :text
    add_column :account_requests, :full_name_ciphertext, :text
    add_column :account_requests, :organisation_name_ciphertext, :text
    add_column :account_requests, :organisation_identifier_ciphertext, :text
    add_column :employments, :organisation_ciphertext, :text
    add_column :employments, :job_title_ciphertext, :text
    add_column :employments, :main_duties_ciphertext, :text
    add_column :feedbacks, :email_ciphertext, :text
    add_column :feedbacks, :email_bidx, :string
    add_index :feedbacks, :email_bidx
    add_column :job_applications, :first_name_ciphertext, :text
    add_column :job_applications, :last_name_ciphertext, :text
    add_column :job_applications, :previous_names_ciphertext, :text
    add_column :job_applications, :street_address_ciphertext, :text
    add_column :job_applications, :city_ciphertext, :text
    add_column :job_applications, :postcode_ciphertext, :text
    add_column :job_applications, :teacher_reference_number_ciphertext, :text
    add_column :job_applications, :national_insurance_number_ciphertext, :text
    add_column :job_applications, :personal_statement_ciphertext, :text
    add_column :job_applications, :support_needed_details_ciphertext, :text
    add_column :job_applications, :close_relationships_details_ciphertext, :text
    add_column :job_applications, :further_instructions_ciphertext, :text
    add_column :job_applications, :rejection_reasons_ciphertext, :text
    add_column :job_applications, :gaps_in_employment_details_ciphertext, :text
    add_column :job_applications, :email_address_ciphertext, :text
    add_column :job_applications, :email_address_bidx, :string
    add_index :job_applications, :email_address_bidx
    add_column :jobseekers, :email_ciphertext, :text
    add_column :jobseekers, :email_bidx, :string
    add_index :jobseekers, :email_bidx
    add_column :jobseekers, :unconfirmed_email_ciphertext, :text
    add_column :jobseekers, :unconfirmed_email_bidx, :string
    add_index :jobseekers, :unconfirmed_email_bidx
    add_column :publishers, :oid_ciphertext, :text
    add_column :publishers, :oid_bidx, :string
    add_index :publishers, :oid_bidx
    add_column :publishers, :email_ciphertext, :text
    add_column :publishers, :email_bidx, :string
    add_index :publishers, :email_bidx
    add_column :publishers, :family_name_ciphertext, :text
    add_column :publishers, :given_name_ciphertext, :text
    add_column :qualifications, :finished_studying_details_ciphertext, :text
    add_column :references, :name_ciphertext, :text
    add_column :references, :job_title_ciphertext, :text
    add_column :references, :organisation_ciphertext, :text
    add_column :references, :email_ciphertext, :text
    add_column :references, :phone_number_ciphertext, :text
    add_column :vacancies, :contact_email_ciphertext, :text
  end
end
