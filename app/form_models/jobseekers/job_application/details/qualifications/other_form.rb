class Jobseekers::JobApplication::Details::Qualifications::OtherForm < Jobseekers::JobApplication::Details::Qualifications::QualificationForm
  validates :category, :finished_studying, :institution, :name, presence: true
end
