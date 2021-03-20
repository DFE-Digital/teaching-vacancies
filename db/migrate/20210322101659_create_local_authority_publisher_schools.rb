class CreateLocalAuthorityPublisherSchools < ActiveRecord::Migration[6.1]
  def change
    create_table :local_authority_publisher_schools, id: :uuid do |t|
      t.uuid :publisher_preference_id
      t.uuid :school_id

      t.timestamps
    end
  end
end
