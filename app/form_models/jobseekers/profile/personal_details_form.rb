require "multistep/form"

class Jobseekers::Profile::PersonalDetailsForm
  include Multistep::Form

  def self.from_record(record)
    new record.attributes.slice(*attribute_names)
  end

  step :name do
    attribute :first_name
    attribute :last_name

    validates :first_name, :last_name, presence: true
  end

  step :phone_number do
    attribute :phone_number_provided
    attribute :phone_number

    validates :phone_number_provided, presence: true
    validates :phone_number, presence: true, format: { with: /\A\+?(?:\d\s?){10,13}\z/ }, if: -> { phone_number_provided == "true" }
  end
end
