class AddReviewedAtTimestampToJobApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :job_applications, :reviewed_at, :datetime
  end
end
