require "rails_helper"

RSpec.describe Jobseekers::JobApplication::FeedbackForm, type: :model do
  it { is_expected.to validate_inclusion_of(:rating).in_array(Feedback.ratings.keys) }
  it { is_expected.to validate_length_of(:comment).is_at_most(1200) }
end
