class Jobseekers::Profile::HideProfileForm < BaseForm
  include ActiveRecord::AttributeAssignment

  attr_accessor :requested_hidden_profile

  validates :requested_hidden_profile, inclusion: { in: [true, false] }

  def initialize(attributes = {})
    self.requested_hidden_profile = ActiveModel::Type::Boolean.new.cast(attributes.delete(:requested_hidden_profile))
    super
  end
end
