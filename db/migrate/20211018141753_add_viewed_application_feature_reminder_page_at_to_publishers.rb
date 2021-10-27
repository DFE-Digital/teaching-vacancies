class AddViewedApplicationFeatureReminderPageAtToPublishers < ActiveRecord::Migration[6.1]
  def change
    add_column :publishers, :viewed_application_feature_reminder_page_at, :datetime
  end
end
