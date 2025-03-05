class Jobseekers::Profile::HideProfileForm < BaseForm
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Attributes

  attribute :requested_hidden_profile, :boolean

  validates :requested_hidden_profile, inclusion: { in: [true, false] }

  # def initialize(attributes = {})
  #   self.requested_hidden_profile = ActiveModel::Type::Boolean.new.cast(attributes.delete(:requested_hidden_profile))
  #   super
  # end
end
