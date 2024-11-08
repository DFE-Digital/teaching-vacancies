class Publishers::JobApplication::TagForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :job_applications

  validates_length_of :job_applications, minimum: 1
end
