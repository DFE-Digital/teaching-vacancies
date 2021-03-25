class AddEmploymentHistoryFieldsToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :gaps_in_employment, :string, default: "", null: false
    add_column :job_applications, :gaps_in_employment_details, :string, default: "", null: false
  end
end
