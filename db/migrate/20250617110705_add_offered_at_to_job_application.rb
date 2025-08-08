class AddOfferedAtToJobApplication < ActiveRecord::Migration[7.2]
  def change
    add_column :job_applications, :offered_at, :datetime
    add_column :job_applications, :declined_at, :datetime
  end
end
