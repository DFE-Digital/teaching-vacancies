class FixupLocalAuthPublisherSchools < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    remove_foreign_key :local_authority_publisher_schools, :organisations, column: :school_id
    add_foreign_key :local_authority_publisher_schools, :organisations, column: :school_id, on_delete: :nullify, validate: false
    validate_foreign_key :local_authority_publisher_schools, :organisations, column: :school_id
  end
end
