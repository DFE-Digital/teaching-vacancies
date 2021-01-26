require "rails_helper"

RSpec.describe Jobseeker, type: :model do
  it { is_expected.to have_many(:saved_jobs) }
  it { is_expected.to have_many(:job_applications) }
end
