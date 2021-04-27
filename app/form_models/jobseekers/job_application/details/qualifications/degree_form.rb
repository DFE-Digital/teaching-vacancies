class Jobseekers::JobApplication::Details::Qualifications::DegreeForm < Jobseekers::JobApplication::Details::Qualifications::QualificationForm
  validates :finished_studying, :institution, :subject1, presence: true

  validates :grade1, presence: true, if: -> { finished_studying == "true" }
end
