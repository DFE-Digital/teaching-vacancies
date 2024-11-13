class RemoveDeviseFieldsFromJobseekers < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column(:jobseekers, :encrypted_password, type: :string, null: false, default: "")
      remove_columns(:jobseekers, :reset_password_token, :confirmation_token, :unconfirmed_email, :unlock_token, type: :string)
      remove_columns(:jobseekers, :reset_password_sent_at, :confirmed_at, :confirmation_sent_at, :locked_at, type: :datetime)
      remove_column(:jobseekers, :failed_attempts, type: :integer, null: false, default: 0)
    end
  end
end
