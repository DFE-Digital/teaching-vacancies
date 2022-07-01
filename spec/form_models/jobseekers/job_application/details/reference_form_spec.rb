require "rails_helper"

RSpec.describe Jobseekers::JobApplication::Details::ReferenceForm, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_presence_of(:organisation) }
  it { is_expected.to validate_presence_of(:relationship) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to allow_value("jacknifedjuggernaut@example.com").for(:email) }
  it { is_expected.not_to allow_value("invalidemail").for(:email) }

  it { is_expected.to allow_value("").for(:phone_number) }
  it { is_expected.to allow_value("01234 123456").for(:phone_number) }
  it { is_expected.not_to allow_value("01234 12345678").for(:phone_number) }
end
