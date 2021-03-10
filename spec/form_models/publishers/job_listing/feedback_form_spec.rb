require "rails_helper"

RSpec.describe Publishers::JobListing::FeedbackForm, type: :model do
  it { is_expected.to validate_inclusion_of(:rating).in_array(Feedback.ratings.keys) }
end
