require 'job_posting'

class SaveJobPostingToVacancyJob < ApplicationJob
  queue_as :seed_vacancies_from_api

  def perform(data)
    job_posting = JobPosting.new(data)
    vacancy = job_posting.to_vacancy

    return if vacancy.save

    Rails.logger.warn("Failed to save vacancy from JobPosting: #{vacancy.errors.messages.inspect}")
  end
end
