require 'teaching_vacancies_api'

namespace :data do
  desc 'Seed from the Teaching Vacancies API'
  namespace :seed_from_api do
    task vacancies: :environment do
      next if Rails.env.production?

      Rails.logger.debug("Seeding vacancies from Teaching Vacancies API in #{Rails.env}")
      job_postings = TeachingVacancies::API.new.jobs(limit: 50)
      job_postings.each do |job_posting|
        SaveJobPostingToVacancyJob.perform_later(job_posting)
      end
    rescue HTTParty::ResponseError => e
      Rails.logger.warn("Teaching Vacancies API response error: #{e.message}")
    end
  end
end
