require "rails_helper"

RSpec.describe DeleteOldFeedbackJob do
  let!(:relevant_feedback) { create(:feedback, created_at: 4.years.ago) }
  let!(:old_feedback) { create(:feedback, created_at: 6.years.ago) }

  before do
    described_class.perform_now
  end

  it "destroys old feedbacks" do
    expect(Feedback.exists?(old_feedback.id)).to be false
  end

  it "does not destroy relevant feedbacks" do
    expect(Feedback.exists?(relevant_feedback.id)).to be true
  end
end
