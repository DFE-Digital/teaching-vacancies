class AddMissingOrganisationIndexes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :organisation_publisher_preferences, :organisation_id, algorithm: :concurrently
    add_index :local_authority_publisher_schools, :school_id, algorithm: :concurrently

    # convert batchable_job_applications into a cascade nullify as it is not a containment relationship
    remove_foreign_key :batchable_job_applications, :job_applications
    add_foreign_key :batchable_job_applications, :job_applications, on_delete: :nullify, validate: false
    validate_foreign_key :batchable_job_applications, :job_applications
  end
end
