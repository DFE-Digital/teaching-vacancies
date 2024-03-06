class Jobseekers::JobApplication::EmploymentHistoryForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[employment_history_section_completed employment_gaps_present]
  end
  attr_accessor(*fields)

  validates :employment_history_section_completed, presence: true
  validate :employment_history_does_not_contain_gaps

  def employment_history_does_not_contain_gaps
    if employment_gaps_present == "true" && employment_history_section_completed == "true"
      errors.add(:gaps, "Cannot complete section while you have unexplained gaps in your work history.")
    end
  end
end
