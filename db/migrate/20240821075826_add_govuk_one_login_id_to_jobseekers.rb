class AddGovukOneLoginIdToJobseekers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :jobseekers, :govuk_one_login_id, :string
    add_index :jobseekers, :govuk_one_login_id, algorithm: :concurrently, unique: true
  end
end
