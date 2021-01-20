require "rails_helper"

RSpec.describe JobApplication, type: :model do
  it { should belong_to(:jobseeker) }
  it { should belong_to(:vacancy) }
end
