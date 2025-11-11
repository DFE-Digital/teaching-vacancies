class AddReminderSentToReferenceRequest < ActiveRecord::Migration[8.0]
  def change
    add_column :reference_requests, :reminder_sent, :boolean, null: false, default: false
  end
end
