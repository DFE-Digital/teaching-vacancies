class AddEmailPreferencesToJobseekers < ActiveRecord::Migration[7.2]
  def change
    add_column :jobseekers, :email_opt_out, :boolean, default: false
    add_column :jobseekers, :email_opt_out_at, :datetime
    add_column :jobseekers, :email_opt_out_reason, :integer
    add_column :jobseekers, :email_opt_out_comment, :text
  end
end
