class AddViewedFeaturesPageAtToPublishers < ActiveRecord::Migration[6.1]
  def change
    add_column :publishers, :viewed_new_features_page_at, :datetime
  end
end
