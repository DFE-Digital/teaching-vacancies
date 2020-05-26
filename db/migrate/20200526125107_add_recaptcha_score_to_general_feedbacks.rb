class AddRecaptchaScoreToGeneralFeedbacks < ActiveRecord::Migration[5.2]
  def change
    add_column :general_feedbacks, :recaptcha_score, :float
  end
end
