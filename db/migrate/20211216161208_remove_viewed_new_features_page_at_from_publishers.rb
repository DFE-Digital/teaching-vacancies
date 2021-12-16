class RemoveViewedNewFeaturesPageAtFromPublishers < ActiveRecord::Migration[6.1]
  def change
    remove_column :publishers, :viewed_new_features_page_at, :datetime
  end
end
