namespace :vacancy do
  desc "backfill all submitted applications to have a PDF version"

  task backfill_application_pdfs: :environment do
    Vacancy.expires_within_data_access_period.find_each do |vacancy|
      vacancy.job_applications.after_submission.reject { |ja| ja.pdf_version.attached? }.each do |job_application|
        MakeJobApplicationPdfJob.perform_later job_application
      end
    end
  end
end
