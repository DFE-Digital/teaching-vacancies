class RenameSchoolTypeFieldsOnOrganisation < ActiveRecord::Migration[6.0]
  def change
    rename_column :organisations, :school_type_name, :school_type
    rename_column :organisations, :detailed_school_type_name, :detailed_school_type
  end
end
