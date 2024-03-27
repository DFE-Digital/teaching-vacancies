class Jobseekers::JobApplication::EmploymentHistoryForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[employment_history_section_completed unexplained_employment_gaps_present]
  end

  def self.unstorable_fields
    %i[unexplained_employment_gaps_present]
  end

  attr_accessor(*fields)

  validates :employment_history_section_completed, presence: true
  validate :employment_history_does_not_contain_gaps

  def employment_history_does_not_contain_gaps
    return unless unexplained_employment_gaps_present == "true" && employment_history_section_completed == "true"

    errors.add(:gaps, "You must provide your full work history, including the reason for any gaps in employment.")
  end
end
