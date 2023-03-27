class Jobseekers::Profile::HideProfileForm < BaseForm
  include ActiveRecord::AttributeAssignment

  attr_accessor :hide_profile

  validates :hide_profile, inclusion: { in: [true, false] }

  def initialize(attributes = {})
    self.hide_profile = ActiveModel::Type::Boolean.new.cast(attributes.delete(:hide_profile))
    super(attributes)
  end
end
