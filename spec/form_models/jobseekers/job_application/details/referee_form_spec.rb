require "rails_helper"

RSpec.describe Jobseekers::JobApplication::Details::RefereeForm, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_presence_of(:organisation) }
  it { is_expected.to validate_presence_of(:relationship) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to allow_value("jacknifedjuggernaut@gmail.com").for(:email) }
  it { is_expected.not_to allow_value("invalidemail").for(:email) }

  it { is_expected.to allow_value("").for(:phone_number) }
  it { is_expected.to allow_value("01234 123456").for(:phone_number) }
  it { is_expected.not_to allow_value("01234 12345678").for(:phone_number) }

  describe "is_most_recent_employer validation" do
    it { is_expected.to allow_value("true").for(:is_most_recent_employer) }
    it { is_expected.to allow_value("false").for(:is_most_recent_employer) }
    it { is_expected.to allow_value(true).for(:is_most_recent_employer) }
    it { is_expected.to allow_value(false).for(:is_most_recent_employer) }
    it { is_expected.not_to allow_value(nil).for(:is_most_recent_employer) }
    it { is_expected.not_to allow_value("abcdefg").for(:is_most_recent_employer) }
  end
end
