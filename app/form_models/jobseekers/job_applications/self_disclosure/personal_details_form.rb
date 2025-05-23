module Jobseekers::JobApplications::SelfDisclosure
  class PersonalDetailsForm < BaseForm
    # include DateAttributeAssignment
    # attr_reader :date_of_birth
    # def date_of_birth=(value)
    #   @date_of_birth = date_from_multiparameter_hash(value)
    # end

    attribute :name, :string
    attribute :previous_names, :string
    attribute :address_line_1, :string
    attribute :address_line_2, :string
    attribute :city, :string
    attribute :country, :string
    attribute :postcode, :string
    attribute :phone_number, :string
    attribute :date_of_birth, :date
    attribute :has_unspent_convictions, :boolean
    attribute :has_spent_convictions, :boolean

    validates :name, presence: true
    validates :address_line_1, presence: true
    validates :city, presence: true
    validates :postcode, presence: true
    validates :phone_number, presence: true
    validates :date_of_birth, presence: true
    validates :has_unspent_convictions, inclusion: { in: [true, false] }
    validates :has_spent_convictions, inclusion: { in: [true, false] }
  end
end
