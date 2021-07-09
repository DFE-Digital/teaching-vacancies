require "rails_helper"

RSpec.describe Publishers::AccountRequestForm, type: :model do
  it { is_expected.to validate_presence_of(:full_name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to allow_value("email@example").for(:email) }
  it { is_expected.to_not allow_value("invalid@email@com").for(:email) }
  it { is_expected.to validate_presence_of(:organisation_name) }
end
