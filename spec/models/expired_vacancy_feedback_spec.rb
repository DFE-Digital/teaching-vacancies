require 'rails_helper'

RSpec.describe ExpiredVacancyFeedback, type: :model do
  it { should belong_to(:vacancy) }
  it { should belong_to(:user) }

  describe 'validations' do
    it { should validate_presence_of :listed_elsewhere }
    it { should validate_presence_of :hired_status }
  end

  describe '#published_on(date)' do
    it 'retrieves feedback submitted on the given date' do
      feedback_today = create_list(:expired_vacancy_feedback, 3)
      feedback_yesterday = create_list(:expired_vacancy_feedback, 2, created_at: 1.day.ago)
      feedback_the_other_day = create_list(:expired_vacancy_feedback, 4, created_at: 2.days.ago)
      feedback_some_other_day = create_list(:expired_vacancy_feedback, 6, created_at: 1.month.ago)

      expect(ExpiredVacancyFeedback.published_on(Time.zone.today).all).to match_array(feedback_today)
      expect(ExpiredVacancyFeedback.published_on(1.day.ago)).to match_array(feedback_yesterday)
      expect(ExpiredVacancyFeedback.published_on(2.days.ago)).to match_array(feedback_the_other_day)
      expect(ExpiredVacancyFeedback.published_on(1.month.ago)).to match_array(feedback_some_other_day)
    end
  end

  describe '#to_row' do
    let(:school) { create(:school) }
    let(:created_at) { '2019-01-01T00:00:00+00:00' }
    let(:user) { create(:user) }
    let(:vacancy) { create(:vacancy, school: school) }
    let(:listed_elsewhere) { :listed_paid }
    let(:hired_status) { :hired_other_free }

    let(:feedback) do
      Timecop.freeze(created_at) do
        create(
          :expired_vacancy_feedback,
          user: user,
          vacancy: vacancy,
          listed_elsewhere: listed_elsewhere,
          hired_status: hired_status
        )
      end
    end

    it 'returns an array of data' do
      expect(feedback.to_row[0]).to eq(Time.zone.now.to_s)
      expect(feedback.to_row[1]).to eq(user.oid)
      expect(feedback.to_row[2]).to eq(vacancy.id)
      expect(feedback.to_row[3]).to eq(school.urn)
      expect(feedback.to_row[4]).to eq(listed_elsewhere.to_s)
      expect(feedback.to_row[5]).to eq(hired_status.to_s)
      expect(feedback.to_row[6]).to eq(feedback.created_at.to_s)
    end
  end
end
