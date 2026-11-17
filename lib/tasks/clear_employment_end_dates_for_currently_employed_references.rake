desc "Clear employment end dates for references where the referee is currently employed"
task clear_employment_end_dates_for_currently_employed_references: :environment do
  JobReference.where(currently_employed: true)
    .where.not(employment_end_date_ciphertext: nil)
    .find_each do |job_reference|
      job_reference.update_column(:employment_end_date, nil)
    end
end
