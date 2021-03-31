require "rails_helper"

RSpec.describe Reference do
  it { is_expected.to belong_to(:job_application) }
end
