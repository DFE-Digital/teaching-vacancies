class RemoveOldBooleanColumns < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      remove_column :employments, :salary, :string, default: "", null: false
      %i[statutory_induction_complete support_needed close_relationships right_to_work_in_uk].each do |job_application_column|
        remove_column :job_applications, job_application_column, :string, default: "", null: false
      end
      remove_column :job_applications, :safeguarding_issue, :string
      remove_column :jobseeker_profiles, :statutory_induction_complete, :string
      # This appears to be unused and confusing
      remove_column :organisations, :readable_phases, :string, array: true
      remove_column :personal_details, :right_to_work_in_uk, :boolean
      remove_column :vacancies, :phase, :integer
    end
  end
end
