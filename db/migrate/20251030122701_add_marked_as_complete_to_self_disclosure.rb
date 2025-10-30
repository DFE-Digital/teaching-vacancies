class AddMarkedAsCompleteToSelfDisclosure < ActiveRecord::Migration[8.0]
  def change
    add_column :self_disclosure_requests, :marked_as_complete, :boolean, null: false, default: false
  end
end
