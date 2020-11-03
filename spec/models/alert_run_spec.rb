require "rails_helper"

RSpec.describe AlertRun, type: :model do
  it { should belong_to(:subscription) }
end