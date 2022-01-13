class JobApplication < ApplicationRecord
  before_save :update_status_timestamp, if: :will_save_change_to_status?
  before_save :anonymise_report, if: :will_save_change_to_status?
  before_save :reset_support_needed_details

  extend ArrayEnum

  array_enum completed_steps: {
    personal_details: 0,
    professional_status: 1,
    qualifications: 2,
    employment_history: 3,
    personal_statement: 4,
    references: 5,
    equal_opportunities: 6,
    ask_for_support: 7,
    declarations: 8,
  }

  # If you want to add a status, be sure to add a `status_at` column to the `job_applications` table
  enum status: { draft: 0, submitted: 1, reviewed: 2, shortlisted: 3, unsuccessful: 4, withdrawn: 5 }, _default: 0

  lockbox_encrypts :first_name, :last_name, :previous_names, :street_address, :city, :postcode, :phone_number,
           :teacher_reference_number, :national_insurance_number, :personal_statement, :support_needed_details,
           :close_relationships_details, :further_instructions, :rejection_reasons,
           :gaps_in_employment_details

  belongs_to :jobseeker
  belongs_to :vacancy

  has_many :qualifications, dependent: :destroy
  has_many :employments, dependent: :destroy
  has_many :references, dependent: :destroy

  has_noticed_notifications

  scope :submitted_yesterday, -> { submitted.where("DATE(submitted_at) = ?", Date.yesterday) }
  scope :after_submission, -> { where(status: %w[submitted reviewed shortlisted unsuccessful withdrawn]) }

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
    Publishers::JobApplicationReceivedNotification.with(vacancy: vacancy, job_application: self).deliver(vacancy.publisher)
    Jobseekers::JobApplicationMailer.application_submitted(self).deliver_later
  end

  def ask_professional_status?
    vacancy.main_job_role.in? %w[teacher leadership]
  end

  private

  def update_status_timestamp
    self["#{status}_at"] = Time.current
  end

  def anonymise_report
    return unless status == "submitted"

    fill_in_report
    reset_equal_opportunities_attributes
  end

  def fill_in_report
    report = vacancy.equal_opportunities_report || vacancy.build_equal_opportunities_report
    Jobseekers::JobApplication::EqualOpportunitiesForm.fields.each do |attr|
      attr_value = public_send(attr)
      next unless attr_value.present?

      if attr.ends_with?("_description")
        attr_name = attr.to_s.split("_").first
        report.public_send("#{attr_name}_other_descriptions") << attr_value
      else
        report.increment("#{attr}_#{attr_value}")
      end
    end
    report.increment(:total_submissions)
    report.save
  end

  def reset_equal_opportunities_attributes
    Jobseekers::JobApplication::EqualOpportunitiesForm.fields.each { |attr| self[attr] = "" }
  end

  def reset_support_needed_details
    self[:support_needed_details] = "" if support_needed == "no"
  end
end
