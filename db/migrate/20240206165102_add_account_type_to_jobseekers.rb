class AddAccountTypeToJobseekers < ActiveRecord::Migration[7.1]
  def change
    add_column :jobseekers, :account_type, :string
  end
end
