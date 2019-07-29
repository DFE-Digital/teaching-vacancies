class SendExpiredVacancyFeedbackEmailJob < ApplicationJob
  queue_as :email_feedback_prompt

  def perform
    expired_vacancies.group_by(&:publisher_user).each do |user, users_vacancies|
      FeedbackPromptMailer.prompt_for_feedback(user.email, users_vacancies).deliver_later unless user.email.nil?
    end
  end

  private

  def expired_vacancies
    Vacancy.where(expires_on: Time.zone.now - 2.weeks, hired_status: nil)
           .where.not(publisher_user: nil)
  end
end
