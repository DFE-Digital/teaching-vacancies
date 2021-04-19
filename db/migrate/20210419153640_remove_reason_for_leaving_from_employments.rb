class RemoveReasonForLeavingFromEmployments < ActiveRecord::Migration[6.1]
  def change
    remove_column :employments, :reason_for_leaving, :string
  end
end
