class SendEmailForDraftJobApplicationsJob < ApplicationJob
  queue_as :default

  def perform
    threshold = Date.today + 10.days

    Vacancy.includes({ job_applications: :jobseeker })
           .where("expires_at between ? and ?", threshold, threshold + 1.day)
           .find_each do |vacancy|
      vacancy.job_applications.draft.each do |job_application|
        Jobseekers::VacancyMailer.draft_application_only(job_application).deliver_later
      end
    end
  end
end
