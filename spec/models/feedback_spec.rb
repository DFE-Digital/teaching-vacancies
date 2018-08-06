require 'rails_helper'

RSpec.describe Feedback, type: :model do
  it { should belong_to(:vacancy) }

  describe '#published_on(date)' do
    it 'retrieves feedback submitted on the given date' do
      feedback_today = create_list(:feedback, 3)
      feedback_yesterday = create_list(:feedback, 2, created_at: 1.day.ago)
      feedback_the_other_day = create_list(:feedback, 4, created_at: 2.days.ago)
      feedback_some_other_day = create_list(:feedback, 6, created_at: 1.month.ago)

      expect(Feedback.published_on(Time.zone.today).all).to eq(feedback_today)
      expect(Feedback.published_on(1.day.ago)).to eq(feedback_yesterday)
      expect(Feedback.published_on(2.days.ago)).to eq(feedback_the_other_day)
      expect(Feedback.published_on(1.month.ago)).to eq(feedback_some_other_day)
    end
  end
end
