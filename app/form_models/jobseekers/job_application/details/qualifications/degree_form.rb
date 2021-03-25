class Jobseekers::JobApplication::Details::Qualifications::DegreeForm < Jobseekers::JobApplication::Details::Qualifications::QualificationForm
  validates :category, :finished_studying, :institution, :subject, presence: true

  validates :grade, presence: true, if: -> { finished_studying == "yes" }
end
