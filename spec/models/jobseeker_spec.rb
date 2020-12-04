require "rails_helper"

RSpec.describe Jobseeker, type: :model do
  it { should have_many(:saved_jobs) }
end
