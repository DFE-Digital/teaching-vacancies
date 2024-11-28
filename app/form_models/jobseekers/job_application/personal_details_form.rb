class Jobseekers::JobApplication::PersonalDetailsForm < Jobseekers::JobApplication::BaseForm
  include ActiveModel::Model

  def self.fields
    %i[
      city country
      email_address
      first_name
      last_name
      national_insurance_number
      phone_number
      previous_names
      postcode
      street_address
      right_to_work_in_uk
      has_ni_number
    ]
  end
  attr_accessor(*(fields - [:national_insurance_number]))
  attr_writer :national_insurance_number

  class << self
    def unstorable_fields
      %i[has_ni_number]
    end

    def load(attrs)
      super(attrs.except(:has_ni_number)).merge(has_ni_number: attrs[:national_insurance_number].present? ? "yes" : "no")
    end
  end

  def national_insurance_number
    @national_insurance_number if has_ni_number == "yes"
  end

  validates :city, :country, :email_address, :first_name, :last_name,
            :phone_number, :postcode, :street_address, presence: true

  validates :national_insurance_number, format: { with: /\A\s*[a-zA-Z]{2}(?:\s*\d\s*){6}[a-zA-Z]?\s*\z/ }, allow_blank: true
  validates :has_ni_number, inclusion: { in: %w[yes no], allow_nil: false }
  validates :national_insurance_number, presence: true, if: -> { has_ni_number == "yes" }

  validates :phone_number, format: { with: /\A\+?(?:\d\s?){10,13}\z/ }
  validates :email_address, email_address: true
  validates :right_to_work_in_uk, inclusion: { in: %w[yes no] }
end
