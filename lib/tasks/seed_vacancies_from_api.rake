namespace :data do
  desc 'Seed from the Teaching Vacancies API'
  namespace :seed_from_api do
    task vacancies: :environment do
      Rails.logger.debug("Seeding vacancies from Teaching Vacancies API in #{Rails.env}")
      job_postings = TeachingVacancies::API.new.jobs(limit: 10)
      job_postings.each do |job_posting|
        SaveJobPostingToVacancyJob.perform_later(job_posting)
      end
    end
  end
end
