class AddIsMostRecentEmployerToReferences < ActiveRecord::Migration[7.2]
  # disabling the three state boolean rule which states boolean columns should always have not null constraint because in this case there is no reasonable way
  # to accurately backfill this column for existing references.
  # rubocop:disable Rails/ThreeStateBooleanColumn
  def change
    add_column :references, :is_most_recent_employer, :boolean
  end
  # rubocop:enable Rails/ThreeStateBooleanColumn
end
