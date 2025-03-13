class Jobseekers::Qualifications::DegreeForm < Jobseekers::Qualifications::QualificationForm
  attr_accessor :subject, :grade

  validates :institution, :subject, presence: true

  validates :finished_studying, inclusion: { in: [true, false] }

  validates :grade, presence: true, if: -> { finished_studying }
end
