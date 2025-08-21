class AddPartialIndexForRetentionPolicy < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    # Add partial index for active job application for retention policy jobs performance
    add_index :job_applications, %i[status submitted_at],
              name: "index_job_applications_on_status_and_submitted_at",
              where: "status != 0",
              algorithm: :concurrently
  end
end
