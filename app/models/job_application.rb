class JobApplication < ApplicationRecord
  before_save :update_status_timestamp, if: %i[will_save_change_to_status? ignore_for_offered_and_declined?]
  before_save :reset_support_needed_details
  before_update :anonymise_report, if: -> { will_save_change_to_status? && status == "submitted" }

  extend ArrayEnum

  array_enum completed_steps: {
    personal_details: 0,
    professional_status: 1,
    qualifications: 2,
    training_and_cpds: 9,
    professional_body_memberships: 12,
    employment_history: 3,
    personal_statement: 4,
    catholic: 10,
    non_catholic: 11,
    referees: 5,
    equal_opportunities: 6,
    ask_for_support: 7,
    declarations: 8,
    upload_application_form: 13,
  }

  array_enum imported_steps: {
    personal_details: 0,
    professional_status: 1,
    qualifications: 2,
    training_and_cpds: 9,
    professional_body_memberships: 12,
    employment_history: 3,
    personal_statement: 4,
    catholic: 10,
    non_catholic: 11,
    referees: 5,
    equal_opportunities: 6,
    ask_for_support: 7,
    declarations: 8,
  }

  array_enum in_progress_steps: {
    qualifications: 0,
    employment_history: 1,
    personal_details: 2,
    professional_status: 3,
    training_and_cpds: 4,
    professional_body_memberships: 12,
    referees: 5,
    equal_opportunities: 6,
    personal_statement: 7,
    declarations: 8,
    ask_for_support: 9,
    catholic: 10,
    non_catholic: 11,
  }

  # If you want to add a status, be sure to add a `status_at` column to the `job_applications` table
  enum :status, { draft: 0, submitted: 1, reviewed: 2, shortlisted: 3, unsuccessful: 4, withdrawn: 5, interviewing: 6, offered: 7, declined: 8 }, default: 0
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

  has_many :notes, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :qualifications, dependent: :destroy
  has_many :employments, dependent: :destroy
  has_many :referees, dependent: :destroy
  has_many :training_and_cpds, dependent: :destroy
  has_many :professional_body_memberships, dependent: :destroy

  has_many :feedbacks, dependent: :destroy, inverse_of: :job_application
  has_one :self_disclosure_request, dependent: :destroy
  has_one :self_disclosure, through: :self_disclosure_request

  has_noticed_notifications

  scope :submitted_yesterday, -> { submitted.where("DATE(submitted_at) = ?", Date.yesterday) }
  scope :after_submission, -> { where.not(status: :draft) }
  scope :draft, -> { where(status: "draft") }

  # end of the road statuses for job application we cannot further update status at the point
  TERMINAL_STATUSES = %w[withdrawn declined].freeze
  scope :active_for_selection, -> { where.not(status: %w[draft] + TERMINAL_STATUSES) }

  validates :email_address, email_address: true, if: -> { email_address_changed? } # Allows data created prior to validation to still be valid

  has_one_attached :baptism_certificate, service: :amazon_s3_documents

  def terminal_status?
    status.in?(TERMINAL_STATUSES)
  end

  def name
    "#{first_name} #{last_name}"
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

  def unexplained_employment_gaps
    @unexplained_employment_gaps ||= Jobseekers::JobApplications::EmploymentGapFinder.new(self).significant_gaps
  end

  def fill_in_report_and_reset_attributes!
    fill_in_report
    reset_equal_opportunities_attributes
    save!
  end

  private

  # predicate method used to ignore the automatic update of `offered_at` and `declined_at` as the are manually entered by publishers
  def ignore_for_offered_and_declined?
    %w[offered declined].exclude?(status)
  end

  def update_status_timestamp
    self["#{status}_at"] = Time.current
  end

  def anonymise_report
    EqualOpportunitiesReportUpdateJob.perform_later(id)
  end

  def fill_in_report
    report = vacancy.equal_opportunities_report || vacancy.build_equal_opportunities_report
    Jobseekers::JobApplication::EqualOpportunitiesForm.storable_fields.each do |attr|
      attr_value = public_send(attr)
      next unless attr_value.present?

      if attr.ends_with?("_description")
        attr_name = attr.to_s.split("_").first
        report.public_send(:"#{attr_name}_other_descriptions") << attr_value
      else
        report.increment("#{attr}_#{attr_value}")
      end
    end
    report.increment(:total_submissions)
    report.save
  end

  def reset_equal_opportunities_attributes
    Jobseekers::JobApplication::EqualOpportunitiesForm.storable_fields.each { |attr| self[attr] = "" }
  end

  def reset_support_needed_details
    self[:support_needed_details] = "" unless is_support_needed?
  end
end
