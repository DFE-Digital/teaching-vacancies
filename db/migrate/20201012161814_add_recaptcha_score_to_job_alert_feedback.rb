class AddRecaptchaScoreToJobAlertFeedback < ActiveRecord::Migration[6.0]
  def change
    add_column :job_alert_feedbacks, :recaptcha_score, :float
  end
end
