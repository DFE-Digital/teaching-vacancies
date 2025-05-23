class Jobseekers::JobApplications::SelfDisclosure::BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attr_reader :model

  def model=(value)
    @model = value
    load_model_data
    model
  end

  def update!
    return unless valid?

    model.assign_attributes(attributes)
    model.save!
  end

  private

  def load_model_data
    # TODO: use assign_attributes
    # assign_attributes(model.attributes.slice(*attributes.keys))
    attributes.each do |m, v|
      public_send(:"#{m}=", model&.public_send(:"#{m}")) if v&.to_s.blank?
    end
  end
end
