class JobApplication < ApplicationRecord
  before_save :update_status_timestamp, if: :will_save_change_to_status?

  extend ArrayEnum

  # If you want to add a status, be sure to add a `status_at` column to the `job_applications` table
  enum :status, { draft: 0, submitted: 1, reviewed: 2, shortlisted: 3, unsuccessful: 4, withdrawn: 5, interviewing: 6 }, default: 0
  array_enum working_patterns: { full_time: 0, part_time: 100, job_share: 101 }

  RELIGIOUS_REFERENCE_TYPES = { referee: 1, baptism_certificate: 2, baptism_date: 3, no_referee: 4 }.freeze

  enum :religious_reference_type, RELIGIOUS_REFERENCE_TYPES

  has_encrypted :first_name, :last_name, :previous_names, :street_address, :city, :postcode,
                :phone_number, :teacher_reference_number, :national_insurance_number,
                :personal_statement, :support_needed_details, :close_relationships_details,
                :further_instructions, :rejection_reasons, :gaps_in_employment_details,
                :faith, :place_of_worship, :baptism_address, :ethos_and_aims,
                :religious_referee_name, :religious_referee_address, :religious_referee_role, :religious_referee_email, :religious_referee_phone
  has_encrypted :baptism_date, type: :date

  belongs_to :jobseeker
  belongs_to :vacancy

  has_many :feedbacks, dependent: :destroy, inverse_of: :job_application

  has_noticed_notifications

  scope :submitted_yesterday, -> { submitted.where("DATE(submitted_at) = ?", Date.yesterday) }
  scope :after_submission, -> { where.not(status: :draft) }
  scope :draft, -> { where(status: "draft") }

  validates :email_address, email_address: true, if: -> { email_address_changed? } # Allows data created prior to validation to still be valid

  has_one_attached :baptism_certificate, service: :amazon_s3_documents

  def name
    "#{first_name} #{last_name}"
  end

  def email
    # This method and its test can be removed once there are no job applications remaining which were submitted before
    # we asked jobseekers for their emails as part of the application.
    email_address.presence || jobseeker.email
  end

  def submit!
    submitted!
    Publishers::JobApplicationReceivedNotifier.with(vacancy: vacancy, job_application: self).deliver(vacancy.publisher)
    Jobseekers::JobApplicationMailer.application_submitted(self).deliver_later
  end

  def for_a_teaching_role?
    vacancy.job_roles.intersect?(%w[teacher headteacher deputy_headteacher assistant_headteacher
                                    head_of_year_or_phase head_of_department_or_curriculum sendco])
  end

  def allow_edit?
    !deadline_passed? && draft?
  end

  def deadline_passed?
    draft? && vacancy&.expired?
  end

  private

  def update_status_timestamp
    self["#{status}_at"] = Time.current
  end
end
