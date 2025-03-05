class Jobseekers::Profile::AddAnotherForm < BaseForm
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Attributes

  attribute :add_another, :boolean

  validates :add_another, inclusion: { in: [true, false] }

  # def initialize(attributes = {})
  #   self.add_another = ActiveModel::Type::Boolean.new.cast(attributes.delete(:add_another))
  #   super
  # end
end
