class AddLockboxCiphertextColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :employments, :organisation_ciphertext, :text
    add_column :employments, :job_title_ciphertext, :text
    add_column :employments, :main_duties_ciphertext, :text
    add_column :job_applications, :first_name_ciphertext, :text
    add_column :job_applications, :last_name_ciphertext, :text
    add_column :job_applications, :previous_names_ciphertext, :text
    add_column :job_applications, :street_address_ciphertext, :text
    add_column :job_applications, :city_ciphertext, :text
    add_column :job_applications, :postcode_ciphertext, :text
    add_column :job_applications, :phone_number_ciphertext, :text
    add_column :job_applications, :teacher_reference_number_ciphertext, :text
    add_column :job_applications, :national_insurance_number_ciphertext, :text
    add_column :job_applications, :personal_statement_ciphertext, :text
    add_column :job_applications, :support_needed_details_ciphertext, :text
    add_column :job_applications, :close_relationships_details_ciphertext, :text
    add_column :job_applications, :further_instructions_ciphertext, :text
    add_column :job_applications, :rejection_reasons_ciphertext, :text
    add_column :job_applications, :gaps_in_employment_details_ciphertext, :text
    add_column :jobseekers, :current_sign_in_ip_ciphertext, :text
    add_column :jobseekers, :last_sign_in_ip_ciphertext, :text
    add_column :publishers, :family_name_ciphertext, :text
    add_column :publishers, :given_name_ciphertext, :text
    add_column :qualifications, :finished_studying_details_ciphertext, :text
    add_column :references, :name_ciphertext, :text
    add_column :references, :job_title_ciphertext, :text
    add_column :references, :organisation_ciphertext, :text
    add_column :references, :email_ciphertext, :text
    add_column :references, :phone_number_ciphertext, :text
  end
end
