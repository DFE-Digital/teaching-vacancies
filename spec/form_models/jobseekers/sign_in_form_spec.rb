require "rails_helper"

RSpec.describe Jobseekers::SignInForm, type: :model do
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to allow_value("valid@example.com").for(:email) }
  it { is_expected.not_to allow_value("invalid_email").for(:email) }
  it { is_expected.to validate_presence_of(:password) }
end
