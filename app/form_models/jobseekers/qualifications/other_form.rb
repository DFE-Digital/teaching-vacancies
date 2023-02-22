class Jobseekers::Qualifications::OtherForm < Jobseekers::Qualifications::QualificationForm
  attr_accessor :subject, :grade

  validates :finished_studying, :institution, :name, presence: true
end
