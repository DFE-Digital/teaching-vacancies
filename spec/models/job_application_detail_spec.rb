require "rails_helper"

RSpec.describe JobApplicationDetail, type: :model do
  it { is_expected.to belong_to(:job_application) }
end
