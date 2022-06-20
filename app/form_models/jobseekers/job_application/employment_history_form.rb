class Jobseekers::JobApplication::EmploymentHistoryForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[employment_history_section_completed]
  end
  attr_accessor(*fields)

  validates :employment_history_section_completed, presence: true
end
