class AddDeletionWarningEmailSentAtToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :deletion_warning_email_sent_at, :datetime
  end
end
