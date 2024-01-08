class AddReasonForLeavingToEmployments < ActiveRecord::Migration[7.0]
  def change
    add_column :employments, :reason_for_leaving, :text
  end
end
