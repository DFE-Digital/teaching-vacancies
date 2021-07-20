class AddBlindIndexOnEmailOnJobseekers < ActiveRecord::Migration[6.1]
  def change
    add_column :jobseekers, :email_bidx, :string
    add_index :jobseekers, :email_bidx
  end
end
