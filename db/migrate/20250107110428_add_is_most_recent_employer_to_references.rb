class AddIsMostRecentEmployerToReferences < ActiveRecord::Migration[7.2]
  def change
    add_column :references, :is_most_recent_employer, :string
  end
end
