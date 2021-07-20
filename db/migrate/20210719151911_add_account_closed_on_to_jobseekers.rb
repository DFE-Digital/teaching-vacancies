class AddAccountClosedOnToJobseekers < ActiveRecord::Migration[6.1]
  def change
    remove_column :jobseekers, :closed_account
    add_column :jobseekers, :account_closed_on, :date
  end
end
