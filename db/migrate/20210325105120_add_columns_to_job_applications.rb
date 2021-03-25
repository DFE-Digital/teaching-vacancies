class AddColumnsToJobApplications < ActiveRecord::Migration[6.1]
  def change
    # Personal details
    add_column :job_applications, :first_name, :string, default: "", null: false
    add_column :job_applications, :last_name, :string, default: "", null: false
    add_column :job_applications, :previous_names, :string, default: "", null: false
    add_column :job_applications, :street_address, :string, default: "", null: false
    add_column :job_applications, :city, :string, default: "", null: false
    add_column :job_applications, :postcode, :string, default: "", null: false
    add_column :job_applications, :phone_number, :string, default: "", null: false
    add_column :job_applications, :teacher_reference_number, :string, default: "", null: false
    add_column :job_applications, :national_insurance_number, :string, default: "", null: false

    # Professional status
    add_column :job_applications, :qualified_teacher_status, :string, default: "", null: false
    add_column :job_applications, :qualified_teacher_status_year, :string, default: "", null: false
    add_column :job_applications, :qualified_teacher_status_details, :text, default: "", null: false
    add_column :job_applications, :statutory_induction_complete, :string, default: "", null: false

    # Personal statement
    add_column :job_applications, :personal_statement, :text, default: "", null: false

    # Ask for support
    add_column :job_applications, :support_needed, :string, default: "", null: false
    add_column :job_applications, :support_needed_details, :text, default: "", null: false

    # Declarations
    add_column :job_applications, :banned_or_disqualified, :string, default: "", null: false
    add_column :job_applications, :close_relationships, :string, default: "", null: false
    add_column :job_applications, :close_relationships_details, :text, default: "", null: false
    add_column :job_applications, :right_to_work_in_uk, :string, default: "", null: false

    # From publisher
    add_column :job_applications, :further_instructions, :text, default: "", null: false
    add_column :job_applications, :rejection_reasons, :text, default: "", null: false
  end
end
