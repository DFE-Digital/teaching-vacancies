class AddViewedNewFeaturesPageAtToPublishers < ActiveRecord::Migration[6.1]
  def change
    add_column :publishers, :dismissed_new_features_page_at, :datetime
  end
end
