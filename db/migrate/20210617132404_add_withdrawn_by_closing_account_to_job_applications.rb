class AddWithdrawnByClosingAccountToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :withdrawn_by_closing_account, :boolean, null: false, default: false
    add_column :job_applications, :status_before_withdrawn, :string
  end
end
