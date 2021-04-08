require "rails_helper"

RSpec.describe Publisher do
  it { is_expected.to have_many(:organisations) }
  it { is_expected.to have_many(:organisation_publishers) }
end
