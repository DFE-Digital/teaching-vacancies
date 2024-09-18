class AddAccountMergeColumnsToJobseekers < ActiveRecord::Migration[7.1]
  def change
    add_column :jobseekers, :account_merge_confirmation_code, :string
    add_column :jobseekers, :account_merge_confirmation_code_generated_at, :datetime
  end
end
