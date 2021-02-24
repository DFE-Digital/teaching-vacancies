class AddDoNotDeleteToSchoolGroupMemberships < ActiveRecord::Migration[6.1]
  def change
    add_column :school_group_memberships, :do_not_delete, :boolean
  end
end
