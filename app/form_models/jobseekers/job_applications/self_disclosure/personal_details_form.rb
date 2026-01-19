module Jobseekers::JobApplications::SelfDisclosure
  class PersonalDetailsForm < BaseForm
    attribute :name, :string
    attribute :previous_names, :string
    attribute :address_line_1, :string
    attribute :address_line_2, :string
    attribute :city, :string
    attribute :country, :string
    attribute :postcode, :string
    attribute :phone_number, :string
    attribute :date_of_birth, :date_or_hash
    attribute :has_unspent_convictions, :boolean
    attribute :has_spent_convictions, :boolean

    validates :name, presence: true
    validates :address_line_1, presence: true
    validates :city, presence: true
    validates :postcode, presence: true
    validates :phone_number, phone_number: true
    validates :date_of_birth, tvs_date: { before: :over_18 }
    validates :has_unspent_convictions, inclusion: { in: [true, false] }
    validates :has_spent_convictions, inclusion: { in: [true, false] }

    def over_18
      18.years.ago
    end
  end
end
