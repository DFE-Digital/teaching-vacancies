class AddEqualOpportunitiesFieldsToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :disability, :string, default: "", null: false
    add_column :job_applications, :gender, :string, default: "", null: false
    add_column :job_applications, :gender_description, :string, default: "", null: false
    add_column :job_applications, :orientation, :string, default: "", null: false
    add_column :job_applications, :orientation_description, :string, default: "", null: false
    add_column :job_applications, :ethnicity, :string, default: "", null: false
    add_column :job_applications, :ethnicity_description, :string, default: "", null: false
    add_column :job_applications, :religion, :string, default: "", null: false
    add_column :job_applications, :religion_description, :string, default: "", null: false
  end
end
