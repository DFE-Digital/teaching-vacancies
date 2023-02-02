class Jobseekers::Profile::Qualifications::QualificationForm
  include ActiveModel::Model

  attr_accessor :category, :finished_studying, :finished_studying_details, :name, :institution, :year

  validates :category, presence: true
  validates :finished_studying_details, presence: true, if: -> { finished_studying == "false" }
  validates :year, numericality: { less_than_or_equal_to: proc { Time.current.year } },
                   if: -> { finished_studying == "true" }
end
