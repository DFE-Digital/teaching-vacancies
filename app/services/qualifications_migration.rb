class QualificationsMigration
  def self.perform
    ActiveRecord::Base.transaction do
      qualifications = Qualification.where(category: 'other_secondary')

      qualifications.find_each do |qualification|
        # Get associated qualification results
        results = qualification.qualification_results
        results.each do |result|
          # Create a new qualification with category 'other'
          Qualification.create!(
            category: 'other',
            subject: result.subject,
            grade: result.grade,
            institution: qualification.institution,
            name: qualification.name,
            year: qualification.year,
            job_application_id: qualification.job_application_id,
            jobseeker_profile_id: qualification.jobseeker_profile_id,
            finished_studying: qualification.finished_studying
          )
        end

        # Delete the original qualification
        qualification.destroy!
      end
    end
  rescue => e
    Rails.logger.error("Error migrating qualifications: #{e.message}")
    raise
  end
end