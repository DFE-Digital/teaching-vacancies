require 'rails_helper'
RSpec.describe SchoolVacancyPresenter do
  let(:vacancy) { create(:vacancy) }
  let(:presenter) { described_class.new(vacancy) }

  describe 'page_views' do
    let(:vacancy) { create(:vacancy, total_pageviews: total_pageviews) }

    context 'when page views are present' do
      let(:total_pageviews) { 100 }

      it 'returns the number' do
        expect(presenter.page_views).to eq(total_pageviews)
      end
    end

    context 'when page views are not present' do
      let(:total_pageviews) { nil }

      it 'returns zero' do
        expect(presenter.page_views).to eq(0)
      end
    end
  end

  describe 'application_deadline' do
    let(:vacancy) { create(:vacancy, expires_on: deadline_date, expiry_time: deadline_time) }
    let(:deadline_date) { Time.zone.today + 5.days }

    context 'when expiry time is not present' do
      let(:deadline_time) { nil }
      let(:expected_deadline) { format_date(deadline_date) }

      it 'displays the application deadline date' do
        expect(presenter.application_deadline).to eq(expected_deadline)
      end
    end

    context 'when expiry time present' do
      let(:deadline_time) { Time.zone.now + 5.days }
      let(:expected_deadline) { format_date(deadline_date) + ' at ' + format_time(deadline_time) }

      it 'displays the application deadline date' do
        expect(presenter.application_deadline).to eq(expected_deadline)
      end
    end
  end

  describe 'days_to_apply' do
    let(:vacancy) { create(:vacancy, expires_on: time_to_apply) }

    context 'with 1 day or less to apply' do
      let(:time_to_apply) { (Time.zone.now + 12.hours) }

      it 'displays if the deadline is today' do
        expect(presenter.days_to_apply).to eq('Deadline is today')
      end
    end

    context 'with more than 1 day to apply' do
      let(:time_to_apply) { (Time.zone.now + 3.days) }

      it 'displays if the deadline is today' do
        expect(presenter.days_to_apply).to eq('3 days remaining to apply')
      end
    end
  end
end
