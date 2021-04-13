class Jobseekers::JobApplication::Details::Qualifications::DegreeForm < Jobseekers::JobApplication::Details::Qualifications::QualificationForm
  validates :finished_studying, :institution, :subject, presence: true

  validates :grade, presence: true, if: -> { finished_studying == "true" }
end
