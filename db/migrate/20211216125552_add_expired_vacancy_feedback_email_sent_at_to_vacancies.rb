class AddExpiredVacancyFeedbackEmailSentAtToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_column :vacancies, :expired_vacancy_feedback_email_sent_at, :datetime
  end
end
