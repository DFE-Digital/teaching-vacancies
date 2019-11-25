class AddLocalAuthorityToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :local_authority, :string
  end
end
