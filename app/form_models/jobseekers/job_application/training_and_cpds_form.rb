class Jobseekers::JobApplication::TrainingAndCpdsForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[training_and_cpds_section_completed]
  end
  attr_accessor(*fields)

  validates :training_and_cpds_section_completed, presence: true
end
