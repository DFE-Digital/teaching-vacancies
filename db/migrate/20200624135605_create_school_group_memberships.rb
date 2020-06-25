class CreateSchoolGroupMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :school_group_memberships, id: :uuid do |t|
      t.uuid :school_id
      t.uuid :school_group_id
    end
  end
end
