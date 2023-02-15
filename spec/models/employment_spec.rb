require "rails_helper"

RSpec.describe Employment do
  it { is_expected.to belong_to(:job_application).optional }
  it { is_expected.to belong_to(:jobseeker_profile).optional }
end
