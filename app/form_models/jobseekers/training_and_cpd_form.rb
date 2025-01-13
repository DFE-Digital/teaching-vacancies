class Jobseekers::TrainingAndCpdForm
  include ActiveModel::Model

  attr_accessor :name, :provider, :grade, :year_awarded, :course_length

  validates :name, :provider, :year_awarded, :course_length, presence: true
end
