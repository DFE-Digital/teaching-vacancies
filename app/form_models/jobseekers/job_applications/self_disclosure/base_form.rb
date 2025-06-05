class Jobseekers::JobApplications::SelfDisclosure::BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include ActiveRecord::AttributeAssignment

  attr_reader :model

  def self.fields
    new.attribute_names
  end

  def model=(value)
    @model = value
    assign_attributes(missing_model_attributes)
    model
  end

  def save_model!
    model.assign_attributes(attributes)
    model.save!
  end

  private

  def missing_model_attributes
    blank_form_attributes = attributes.select { |_, v| v&.to_s.blank? }.keys
    model.attributes.slice(*blank_form_attributes)
  end
end
