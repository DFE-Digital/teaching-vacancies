require "rails_helper"

RSpec.describe SavedJob, type: :model do
  it { should belong_to(:jobseeker) }
  it { should belong_to(:vacancy) }
end
