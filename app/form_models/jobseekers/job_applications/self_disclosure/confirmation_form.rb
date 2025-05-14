class Jobseekers::JobApplications::SelfDisclosure::ConfirmationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :agreements
  attribute :signature, :string

  validates :agreements, presence: true
  validates :signature, presence: true
end
