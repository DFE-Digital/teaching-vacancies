class Jobseekers::JobApplications::SelfDisclosure::BaseForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attr_accessor :model

  delegate :valid?, :save!, :errors, to: :model

  def load_model_data
    attributes.each do |m, v|
      public_send(:"#{m}=", model&.public_send(:"#{m}")) if v.blank?
    end
  end
end
