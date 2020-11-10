class SendExpiredVacancyFeedbackEmailJob < ApplicationJob
  queue_as :email_feedback_prompt

  def perform
    expired_vacancies.group_by(&:publisher_user).each do |user, users_vacancies|
      unless user.email.nil?
        FeedbackPromptMailer.prompt_for_feedback(user.email, users_vacancies).deliver_later
        Rails.logger.info("Sidekiq: Sending feedback prompt emails for #{users_vacancies.count} vacancies")
      end
    end
  end

private

  def expired_vacancies
    Vacancy.where(expires_on: Time.current - 2.weeks, hired_status: nil)
           .where.not(publisher_user: nil)
  end
end
