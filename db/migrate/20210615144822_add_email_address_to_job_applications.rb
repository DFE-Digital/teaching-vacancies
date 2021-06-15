class AddEmailAddressToJobApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :email_address, :string, default: "", null: false
  end
end
