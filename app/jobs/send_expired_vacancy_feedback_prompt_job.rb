class SendExpiredVacancyFeedbackPromptJob < ApplicationJob
  queue_as :low

  MAX_NUMBER_OF_VACANCIES = 5

  CUTOFF_DATE = 6.weeks.ago.beginning_of_day

  def perform
    vacancies_requiring_expiry_email_prompt.group_by(&:publisher).each do |publisher, expired_vacancies|
      next unless publisher.email == "ben.mitchell@digital.education.gov.uk"

      vacancies_to_include = expired_vacancies.sort_by(&:expires_at).first(MAX_NUMBER_OF_VACANCIES)

      next unless publisher.email.present? && publisher.unsubscribed_from_expired_vacancy_prompt_at.nil?

      Publishers::ExpiredVacancyFeedbackPromptMailer.prompt_for_feedback(publisher, vacancies_to_include).deliver_later
      Rails.logger.info("Sidekiq: Sending feedback prompt emails for #{vacancies_to_include.count} vacancies to #{publisher.email}")

      vacancies_to_include.each { |vacancy| vacancy.update(expired_vacancy_feedback_email_sent_at: Time.zone.now) }
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
