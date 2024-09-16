require "rails_helper"

RSpec.describe Jobseekers::JobApplication::PersonalDetailsForm, type: :model do
  it { is_expected.to validate_presence_of(:street_address) }
  it { is_expected.to validate_presence_of(:postcode) }
  it { is_expected.to validate_presence_of(:city) }
  it { is_expected.to validate_presence_of(:country) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }

  it { is_expected.to allow_value("AB 12 12 12 A").for(:national_insurance_number) }
  it { is_expected.not_to allow_value("AB 12 12 12 A 12").for(:national_insurance_number) }

  it { is_expected.to validate_presence_of(:email_address) }
  it { is_expected.to allow_value("david@example.com").for(:email_address) }
  it { is_expected.not_to allow_value("david at example.com").for(:email_address) }

  it { is_expected.to validate_presence_of(:phone_number) }
  it { is_expected.to allow_value("01234 12345678").for(:phone_number) }
  it { is_expected.not_to allow_value("01234 123456789").for(:phone_number) }

  it { is_expected.to validate_inclusion_of(:right_to_work_in_uk).in_array(%w[yes no]) }
end
