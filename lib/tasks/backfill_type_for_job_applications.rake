namespace :job_applications do
  desc "Backfill job application type where it's nil"
  task backfill_type: :environment do
    JobApplication.where(type: nil).update_all(type: "NativeJobApplication")
  end
end
