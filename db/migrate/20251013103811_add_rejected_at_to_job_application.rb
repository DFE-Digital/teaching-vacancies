class AddRejectedAtToJobApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :job_applications, :rejected_at, :datetime
  end
end
