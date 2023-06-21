require "rails_helper"

RSpec.describe CookiesPreferencesForm, type: :model do
  it { is_expected.to validate_inclusion_of(:cookies_analytics_consent).in_array(%w[yes no]) }
  it { is_expected.to validate_inclusion_of(:cookies_marketing_consent).in_array(%w[yes no]) }
end
