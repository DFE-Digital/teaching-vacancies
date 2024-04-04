class Jobseekers::TrainingAndCpdForm
  include ActiveModel::Model

  attr_accessor :name, :provider, :grade, :year_awarded

  validates :name, :provider, :year_awarded, presence: true
end