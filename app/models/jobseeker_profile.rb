class JobseekerProfile < ApplicationRecord
  include ProfileSection

  belongs_to :jobseeker

  has_one :personal_details, dependent: :destroy
  has_one :job_preferences, dependent: :destroy
  has_many :employments, dependent: :destroy
  has_many :qualifications, dependent: :destroy
  has_many :training_and_cpds, dependent: :destroy
  has_many :organisation_exclusions, class_name: "JobseekerProfileExcludedOrganisation", dependent: :destroy
  has_many :excluded_organisations, through: :organisation_exclusions, source: :organisation

  delegate :all_roles, to: :job_preferences
  delegate :all_key_stages, to: :job_preferences
  delegate :all_working_patterns, to: :job_preferences
  delegate :first_name, :last_name, to: :personal_details, allow_nil: true

  scope :active, -> { where(active: true) }
  scope :not_hidden_from, lambda { |organisation|
    relevant_orgs = [organisation]
    relevant_orgs += organisation.school_groups if organisation.respond_to?(:school_groups)

    hidden_profile_ids = JobseekerProfileExcludedOrganisation
      .where(organisation: relevant_orgs)
      .pluck(:jobseeker_profile_id)

    where.not(id: hidden_profile_ids)
  }

  delegate :email, to: :jobseeker

  delegate :first_name, :last_name, to: :personal_details, allow_nil: true

  enum qualified_teacher_status: { yes: 0, no: 1, on_track: 2, non_teacher: 3 }

  validates :jobseeker, uniqueness: true

  def self.copy_attributes(record, previous_application)
    record.assign_attributes(
      employments: previous_application.employments.map(&:duplicate),
      qualifications: previous_application.qualifications.map(&:duplicate),
      qualified_teacher_status_year: previous_application.qualified_teacher_status_year,
      qualified_teacher_status: previous_application.qualified_teacher_status,
    )
  end

  def self.prepare_associations(record)
    record.assign_attributes(
      job_preferences: JobPreferences.prepare(jobseeker_profile: record),
      personal_details: PersonalDetails.prepare(jobseeker_profile: record),
    )
  end

  def self.jobseeker(record)
    record.jobseeker
  end

  def replace_qualifications!(new_qualifications)
    transaction do
      qualifications.destroy_all
      update!(qualifications: new_qualifications)
    end
  end

  def replace_employments!(new_employments)
    transaction do
      employments.destroy_all
      update!(employments: new_employments)
    end
  end

  def deactivate!
    return unless active?

    update_column(:active, false)
  end

  def full_name
    [first_name, last_name].join(" ").presence || "Jobseeker"
  end

  def qts_status
    case qualified_teacher_status
    when "yes"
      "Awarded QTS #{qualified_teacher_status_year}"
    when "on_track"
      "On track to receive QTS"
    else
      ""
    end
  end

  def activable?
    !!personal_details&.complete? && !!job_preferences&.complete?
  end

  def hidden_from_any_organisations?
    requested_hidden_profile && excluded_organisations.any?
  end

  def unexplained_employment_gaps
    @unexplained_employment_gaps ||= Jobseekers::JobApplications::EmploymentGapFinder.new(self).significant_gaps
  end
end
