class Jobseekers::JobApplication::Details::Qualifications::OtherForm < Jobseekers::JobApplication::Details::Qualifications::QualificationForm
  attr_accessor :subject, :grade

  validates :finished_studying, :institution, :name, presence: true
end
