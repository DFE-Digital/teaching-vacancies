class Jobseekers::JobApplication::EmploymentHistoryForm
  include ActiveModel::Model

  attr_accessor :gaps_in_employment, :gaps_in_employment_details

  validates :gaps_in_employment, inclusion: { in: %w[yes no] }
end
