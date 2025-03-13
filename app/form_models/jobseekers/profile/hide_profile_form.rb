class Jobseekers::Profile::HideProfileForm < BaseForm
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Attributes

  attribute :requested_hidden_profile, :boolean

  validates :requested_hidden_profile, inclusion: { in: [true, false] }
end
