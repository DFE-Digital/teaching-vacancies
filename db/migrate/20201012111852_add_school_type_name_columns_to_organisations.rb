class AddSchoolTypeNameColumnsToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :detailed_school_type_name, :string
    add_column :organisations, :school_type_name, :string
  end
end
