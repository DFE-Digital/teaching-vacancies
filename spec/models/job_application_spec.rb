require "rails_helper"

RSpec.describe JobApplication, type: :model do
  it { is_expected.to belong_to(:jobseeker) }
  it { is_expected.to belong_to(:vacancy) }
  it { is_expected.to have_many(:job_application_details) }
  it { is_expected.to have_many(:references) }
end
