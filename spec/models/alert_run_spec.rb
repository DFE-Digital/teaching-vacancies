require "rails_helper"

RSpec.describe AlertRun, type: :model do
  it { is_expected.to belong_to(:subscription) }
end
