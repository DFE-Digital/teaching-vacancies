class RemoveAccountTypeFromJobseekers < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :jobseekers, :account_type, :string }
  end
end
