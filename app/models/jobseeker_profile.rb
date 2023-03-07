class JobseekerProfile < ApplicationRecord
  belongs_to :jobseeker

  has_one :personal_details
  has_one :job_preferences
  has_many :employments
  has_many :qualifications

  enum qualified_teacher_status: { yes: 0, no: 1, on_track: 2 }

  def self.prepare(jobseeker:)
    find_or_initialize_by(jobseeker:).tap do |record|
      if record.new_record?
        if (previous_application = jobseeker.job_applications.last)
          record.assign_attributes(
            employments: previous_application.employments.map(&:duplicate),
            qualifications: previous_application.qualifications.map(&:duplicate),
            qualified_teacher_status_year: previous_application.qualified_teacher_status_year,
            qualified_teacher_status: previous_application.qualified_teacher_status,
          )
        end

        record.assign_attributes(
          job_preferences: JobPreferences.prepare(profile: record),
          personal_details: PersonalDetails.prepare(profile: record),
        )

        yield record if block_given?

        record.save!
      end
    end
  end

  def deactivate!
    return unless active?

    update_column(:active, false)
  end
end
