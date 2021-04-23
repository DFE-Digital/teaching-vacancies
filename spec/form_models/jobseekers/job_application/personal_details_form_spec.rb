require "rails_helper"

RSpec.describe Jobseekers::JobApplication::PersonalDetailsForm, type: :model do
  it { is_expected.to validate_presence_of(:street_address) }
  it { is_expected.to validate_presence_of(:postcode) }
  it { is_expected.to validate_presence_of(:city) }

  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }

  it { is_expected.to allow_value("AB 12 12 12 A").for(:national_insurance_number) }
  it { is_expected.not_to allow_value("AB 12 12 12 A 12").for(:national_insurance_number) }

  it { is_expected.to validate_presence_of(:phone_number) }
  it { is_expected.to allow_value("01234 123456").for(:phone_number) }
  it { is_expected.not_to allow_value("01234 12345678").for(:phone_number) }

  it { is_expected.to allow_value("1234567").for(:teacher_reference_number) }
  it { is_expected.to allow_value("").for(:teacher_reference_number) }
  it { is_expected.not_to allow_value("1234567891011").for(:teacher_reference_number) }
  it { is_expected.not_to allow_value("ABCD").for(:teacher_reference_number) }
end
