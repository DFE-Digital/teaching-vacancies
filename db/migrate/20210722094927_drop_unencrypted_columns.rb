class DropUnencryptedColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :employments, :organisation
    remove_column :employments, :job_title
    remove_column :employments, :main_duties
    remove_column :job_applications, :first_name
    remove_column :job_applications, :last_name
    remove_column :job_applications, :previous_names
    remove_column :job_applications, :street_address
    remove_column :job_applications, :city
    remove_column :job_applications, :postcode
    remove_column :job_applications, :phone_number
    remove_column :job_applications, :teacher_reference_number
    remove_column :job_applications, :national_insurance_number
    remove_column :job_applications, :personal_statement
    remove_column :job_applications, :support_needed_details
    remove_column :job_applications, :close_relationships_details
    remove_column :job_applications, :further_instructions
    remove_column :job_applications, :rejection_reasons
    remove_column :job_applications, :gaps_in_employment_details
    remove_column :jobseekers, :last_sign_in_ip
    remove_column :jobseekers, :current_sign_in_ip
    remove_column :publishers, :family_name
    remove_column :publishers, :given_name
    remove_column :qualifications, :finished_studying_details
    remove_column :references, :name
    remove_column :references, :job_title
    remove_column :references, :organisation
    remove_column :references, :email
    remove_column :references, :phone_number
  end
end
