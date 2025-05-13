namespace :job_applications do
  desc "Update working_patterns to replace 'job_share' with 'part_time' and set is_job_share to true"
  task backfill_type: :environment do
    JobApplication.update_all(type: 'NativeJobApplication')
  end
end
