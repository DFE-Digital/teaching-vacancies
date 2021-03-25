class Jobseekers::JobApplication::Details::Qualifications::QualificationForm
  include ActiveModel::Model

  attr_accessor :category, :finished_studying, :finished_studying_details, :grade, :name, :institution, :subject, :year

  validates :finished_studying_details, presence: true, if: -> { finished_studying == "false" }
  validates :year, presence: true, if: -> { finished_studying == "true" }
  validates :year, format: { with: /\A\d{4}\z/.freeze }, if: -> { year.present? }
end
