require "rails_helper"

RSpec.describe Notification do
  it { is_expected.to belong_to(:recipient) }
end
