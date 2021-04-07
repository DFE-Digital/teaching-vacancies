class JobApplication < ApplicationRecord
  before_save :update_status_timestamp, if: :will_save_change_to_status?
  before_save :anonymise_report, if: :will_save_change_to_status?

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

  array_enum in_progress_steps: {
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
  enum status: { draft: 0, submitted: 1, shortlisted: 2, unsuccessful: 3, withdrawn: 4 }, _default: 0

  belongs_to :jobseeker
  belongs_to :vacancy

  has_many :qualifications, dependent: :destroy
  has_many :employments, dependent: :destroy
  has_many :references, dependent: :destroy

  scope :submitted_yesterday, -> { submitted.where("DATE(submitted_at) = ?", Date.yesterday) }

  def submit!
    submitted!
    Publishers::JobApplicationReceivedNotification.with(vacancy: vacancy, job_application: self).deliver(vacancy.publisher)
    Jobseekers::JobApplicationMailer.application_submitted(self).deliver_later
  end

  def qualification_groups
    # When qualifications match on name, institution, and year, group/merge them into single objects for displaying.
    qualifications.group_by { |qual| [qual.name, qual.institution, qual.year] }
                  .values
                  .sort_by { |group| group.min_by(&:created_at).created_at }
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
    Jobseekers::JobApplication::EqualOpportunitiesForm::ATTRIBUTES.each do |attr|
      attr_value = public_send(attr)
      if attr.ends_with?("_description")
        next unless attr_value.present?

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
    Jobseekers::JobApplication::EqualOpportunitiesForm::ATTRIBUTES.each { |attr| self[attr] = "" }
  end
end
