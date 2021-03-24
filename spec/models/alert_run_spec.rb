require "rails_helper"

RSpec.describe AlertRun do
  it { is_expected.to belong_to(:subscription) }
end
