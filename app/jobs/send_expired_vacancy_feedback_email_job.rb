class SendExpiredVacancyFeedbackEmailJob < ApplicationJob
  queue_as :low

  def perform
    expired_vacancies.group_by(&:publisher).each do |publisher, publisher_vacancies|
      unless publisher.email.nil?
        Publishers::FeedbackPromptMailer.prompt_for_feedback(publisher, publisher_vacancies).deliver_later
        Rails.logger.info("Sidekiq: Sending feedback prompt emails for #{publisher_vacancies.count} vacancies")
      end
    end
  end

  private

  def expired_vacancies
    Vacancy.where(expires_at: 2.weeks.ago.beginning_of_day..2.weeks.ago.end_of_day, hired_status: nil)
           .where.not(publisher: nil)
  end
end
