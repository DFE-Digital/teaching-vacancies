require 'rails_helper'

RSpec.describe GeneralFeedback, type: :model do
  describe 'validations' do
    it { should validate_presence_of :visit_purpose }
    it { should validate_length_of(:visit_purpose_comment).is_at_most(1200) }
    it { should validate_length_of(:comment).is_at_most(1200) }
    it { should validate_presence_of :user_participation_response }
  end

  describe '#published_on(date)' do
    it 'retrieves feedback submitted on the given date' do
      feedback_today = create_list(:general_feedback, 3)
      feedback_yesterday = create_list(:general_feedback, 2, created_at: 1.day.ago)
      feedback_the_other_day = create_list(:general_feedback, 4, created_at: 2.days.ago)
      feedback_some_other_day = create_list(:general_feedback, 6, created_at: 1.month.ago)

      expect(GeneralFeedback.published_on(Time.zone.today).all).to match_array(feedback_today)
      expect(GeneralFeedback.published_on(1.day.ago)).to match_array(feedback_yesterday)
      expect(GeneralFeedback.published_on(2.days.ago)).to match_array(feedback_the_other_day)
      expect(GeneralFeedback.published_on(1.month.ago)).to match_array(feedback_some_other_day)
    end
  end

  describe '#to_row' do
    let(:created_at) { '2019-01-01T00:00:00+00:00' }
    let(:visit_purpose) { :other_purpose }
    let(:visit_purpose_comment) { 'For reasons...' }
    let(:comment) { 'Great!' }

    let(:feedback) do
      Timecop.freeze(created_at) do
        create(:general_feedback, visit_purpose: visit_purpose,
                                  visit_purpose_comment: visit_purpose_comment,
                                  comment: comment)
      end
    end

    it 'returns an array of data' do
      expect(feedback.to_row[0]).to eq(Time.zone.now.to_s)
      expect(feedback.to_row[1]).to eq(visit_purpose.to_s)
      expect(feedback.to_row[2]).to eq(visit_purpose_comment)
      expect(feedback.to_row[3]).to eq(nil) # Rating column: we no longer take these as feedback
      expect(feedback.to_row[4]).to eq(comment)
      expect(feedback.to_row[5]).to eq(feedback.created_at.to_s)
    end
  end
end
