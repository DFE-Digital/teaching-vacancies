class RemoveReferenceFromSubscriptions < ActiveRecord::Migration[6.0]
  def change
    remove_column :subscriptions, :reference, :string
  end
end
