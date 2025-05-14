class Jobseekers::JobApplications::SelfDisclosure::BarredListForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :is_barred, :boolean
  attribute :has_been_referred, :boolean

  validates :is_barred, inclusion: { in: [true, false] }
  validates :has_been_referred, inclusion: { in: [true, false] }
end
