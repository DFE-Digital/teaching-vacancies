class AddSafeguardingIssuesToJobApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :job_applications, :safeguarding_issue, :string
    add_column :job_applications, :safeguarding_issue_details, :text
  end
end
