class Jobseekers::Profile::Qualifications::OtherForm < Jobseekers::Profile::Qualifications::QualificationForm
  attr_accessor :subject, :grade

  validates :finished_studying, :institution, :name, presence: true
end
