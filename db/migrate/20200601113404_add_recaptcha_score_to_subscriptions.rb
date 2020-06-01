class AddRecaptchaScoreToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :recaptcha_score, :float
  end
end
