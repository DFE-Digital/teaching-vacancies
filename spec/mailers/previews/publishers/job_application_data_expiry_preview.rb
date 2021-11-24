# Documentation: app/mailers/previewing_emails.md
class Publishers::JobApplicationDataExpiryPreview < ActionMailer::Preview
  def job_application_data_expiry
    Publishers::JobApplicationDataExpiryMailer.with(publisher: Publisher.first, vacancy: Vacancy.first).job_application_data_expiry
  end
end
