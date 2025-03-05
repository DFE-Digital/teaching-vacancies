class Jobseekers::Qualifications::OtherForm < Jobseekers::Qualifications::QualificationForm
  attr_accessor :subject, :grade

  validates :institution, :name, presence: true

  validates :finished_studying, inclusion: { in: [true, false] }

  validates :grade, presence: true, if: -> { finished_studying }
end
