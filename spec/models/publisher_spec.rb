require "rails_helper"

RSpec.describe Publisher do
  it { is_expected.to have_many(:organisations) }
  it { is_expected.to have_many(:organisation_publishers) }
  it { is_expected.to have_many(:publisher_preferences) }
  it { is_expected.to have_many(:emergency_login_keys) }
  it { is_expected.to have_many(:vacancies) }
  it { is_expected.to have_many(:notifications) }
end
