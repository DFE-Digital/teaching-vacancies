require "rails_helper"

RSpec.describe Jobseekers::JobAlertFurtherFeedbackForm, type: :model do
  it { is_expected.to validate_presence_of(:comment) }
  it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
end
