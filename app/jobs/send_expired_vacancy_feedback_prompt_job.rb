class SendExpiredVacancyFeedbackPromptJob < ApplicationJob
  queue_as :low

  MAX_NUMBER_OF_VACANCIES = 5

  CUTOFF_DATE = 6.weeks.ago.beginning_of_day

  def perform
    vacancies_requiring_expiry_email_prompt.each do |expired_vacancy|
      next unless expired_vacancy.publisher.email.present? && expired_vacancy.publisher.unsubscribed_from_expired_vacancy_prompt_at.nil?

      Publishers::ExpiredVacancyFeedbackPromptMailer.prompt_for_feedback(expired_vacancy.publisher, expired_vacancy).deliver_later

      Rails.logger.info("Sidekiq: Sending feedback prompt emails for vacancy id: #{expired_vacancy.id} vacancies to #{expired_vacancy.publisher.email}")

      expired_vacancy.update(expired_vacancy_feedback_email_sent_at: Time.zone.now)
    end
  end

  private

  def vacancies_requiring_expiry_email_prompt
    Vacancy.listed.where(expires_at: CUTOFF_DATE..2.weeks.ago.beginning_of_day,
                         hired_status: nil,
                         expired_vacancy_feedback_email_sent_at: nil)
                  .where.not(publisher: nil)
  end
end
