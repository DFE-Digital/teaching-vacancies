class QualificationsMigration
  def self.perform
    ActiveRecord::Base.transaction do
      Qualification.includes(:qualification_results).where(category: "other_secondary").find_each(batch_size: 500) do |qualification|
        qualification.qualification_results.each do |result|
          Qualification.create!(category: "other", subject: result.subject, grade: result.grade, awarding_body: result.awarding_body,
                                institution: qualification.institution, name: qualification.name, year: qualification.year,
                                job_application_id: qualification.job_application_id, jobseeker_profile_id: qualification.jobseeker_profile_id,
                                finished_studying: qualification.finished_studying)
        end

        qualification.destroy!
      end
    end
  rescue StandardError => e
    Rails.logger.error("Error migrating qualifications: #{e.message}")
    raise
  end
end
