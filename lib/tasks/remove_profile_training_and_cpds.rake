namespace :jobseekers do
  desc "Remove Training and CPD records that belong to jobseeker profiles"
  task remove_profile_training_and_cpds: :environment do
    TrainingAndCpd.where.not(jobseeker_profile_id: nil).delete_all
  end
end
