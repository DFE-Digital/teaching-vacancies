class SendEmailForUnappliedSavedVacanciesJob < ApplicationJob
  queue_as :default

  def perform
    threshold = Date.today + 10.days

    Vacancy.includes({ job_applications: :jobseeker }, { saved_jobs: :jobseeker })
           .where("expires_at between ? and ?", threshold, threshold + 1.day)
           .find_each do |vacancy|
      applicants = vacancy.job_applications.map(&:jobseeker)
      vacancy.saved_jobs.map(&:jobseeker).reject { |js| applicants.include?(js) }.each do |jobseeker|
        Jobseekers::VacancyMailer.unapplied_saved_vacancy(vacancy, jobseeker).deliver_later
      end
    end
  end
end
