class AddIndexToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_index :subscriptions, [:email, :search_criteria, :status, :frequency, :expires_on],
                              name: :sub_email_search_criteria_status_frequency_expires_on_index
  end
end
