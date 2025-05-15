module Jobseekers::JobApplications::SelfDisclosure
  class PersonalDetailsForm < BaseForm
    # include DateAttributeAssignment

    attribute :name, :string
    attribute :previous_names, :string
    attribute :address_line_1, :string
    attribute :address_line_2, :string
    attribute :city, :string
    attribute :county, :string
    attribute :postcode, :string
    attribute :phone_number, :string
    attribute :date_of_birth, :date
    attribute :has_unspent_convictions, :boolean
    attribute :has_spent_convictions, :boolean

    # attr_reader :date_of_birth

    # def date_of_birth=(value)
    #   @date_of_birth = date_from_multiparameter_hash(value)
    # end
  end
end
