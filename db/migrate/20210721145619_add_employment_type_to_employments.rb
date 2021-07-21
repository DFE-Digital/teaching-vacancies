class AddEmploymentTypeToEmployments < ActiveRecord::Migration[6.1]
  def change
    add_column :employments, :employment_type, :integer, default: 0
    add_column :employments, :reason_for_break, :text, default: ""
  end
end
