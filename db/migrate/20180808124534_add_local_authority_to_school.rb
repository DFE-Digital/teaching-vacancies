class AddLocalAuthorityToSchool < ActiveRecord::Migration[5.1]
  def change
    add_column :schools, :local_authority_id, :uuid, foreign_key: true
    add_index :schools, :local_authority_id
  end
end
