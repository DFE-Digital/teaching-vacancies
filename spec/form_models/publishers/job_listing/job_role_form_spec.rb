require "rails_helper"

RSpec.describe Publishers::JobListing::JobRoleForm, type: :model do
  it { is_expected.to validate_presence_of(:job_role) }
end
