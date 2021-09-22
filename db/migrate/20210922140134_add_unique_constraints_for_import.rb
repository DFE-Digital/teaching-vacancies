class AddUniqueConstraintsForImport < ActiveRecord::Migration[6.1]
  def change
    add_index :organisations, :local_authority_code, unique: true

    # Has existing index, but it isn't unique
    remove_index :organisations, :urn
    add_index :organisations, :urn, unique: true

    # Has existing index, but it isn't unique
    remove_index :organisations, :uid
    add_index :organisations, :uid, unique: true

    add_index :school_group_memberships, %i[school_id school_group_id], unique: true
  end
end
