#
# Ensure existing job_applications get set to false to stay valid
#
namespace :job_application do
  desc "Backfill job_application.notify_before_contact_referers"
  task notify_before_contact_referers: :environment do
    JobApplication.where(notify_before_contact_referers: nil).update_all(notify_before_contact_referers: false)
  end
end
