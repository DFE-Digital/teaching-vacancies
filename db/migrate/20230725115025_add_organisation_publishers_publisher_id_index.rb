class AddOrganisationPublishersPublisherIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :organisation_publishers, ["publisher_id"], name: :index_organisation_publishers_publisher_id, algorithm: :concurrently
  end
end
