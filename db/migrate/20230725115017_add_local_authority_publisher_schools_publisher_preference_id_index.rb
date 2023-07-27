class AddLocalAuthorityPublisherSchoolsPublisherPreferenceIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :local_authority_publisher_schools, ["publisher_preference_id"], name: :index_local_authority_publisher_schools_publisher_preference_id, algorithm: :concurrently
  end
end
