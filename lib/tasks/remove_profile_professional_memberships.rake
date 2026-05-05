desc "Remove professional body memberships from profile"
task remove_profile_professional_memberships: :environment do
  ProfessionalBodyMembership.where(job_application_id: nil).find_in_batches do |pbm_batch|
    ProfessionalBodyMembership.transaction do
      pbm_batch.each(&:destroy!)
    end
  end
end
