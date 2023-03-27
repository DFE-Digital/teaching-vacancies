class Jobseekers::Profile::AddAnotherForm < BaseForm
  include ActiveRecord::AttributeAssignment

  attr_accessor :add_another

  validates :add_another, inclusion: { in: [true, false] }

  def initialize(attributes = {})
    self.add_another = ActiveModel::Type::Boolean.new.cast(attributes.delete(:add_another))
    super(attributes)
  end
end
