require "rails_helper"

RSpec.describe JobApplicationDetail do
  it { is_expected.to belong_to(:job_application) }
end
