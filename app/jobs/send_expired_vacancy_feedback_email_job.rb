class SendExpiredVacancyFeedbackEmailJob < ApplicationJob
  queue_as :low

  def perform
    expired_vacancies.group_by(&:publisher).each do |publisher, publisher_vacancies|
      unless publisher.email.nil?
        FeedbackPromptMailer.prompt_for_feedback(publisher.email, publisher_vacancies).deliver_later
        Rails.logger.info("Sidekiq: Sending feedback prompt emails for #{publisher_vacancies.count} vacancies")
      end
    end
  end

  private

  def expired_vacancies
    Vacancy.where(expires_on: Time.current - 2.weeks, hired_status: nil)
           .where.not(publisher: nil)
  end
end
