class Jobseekers::Profile::AddAnotherForm < BaseForm
  include ActiveRecord::AttributeAssignment
  include ActiveModel::Attributes

  attribute :add_another, :boolean

  validates :add_another, inclusion: { in: [true, false] }
end
