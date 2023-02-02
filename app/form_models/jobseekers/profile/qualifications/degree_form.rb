class Jobseekers::Profile::Qualifications::DegreeForm < Jobseekers::JobApplication::Details::Qualifications::QualificationForm
  attr_accessor :subject, :grade

  validates :finished_studying, :institution, :subject, presence: true

  validates :grade, presence: true, if: -> { finished_studying == "true" }
end
