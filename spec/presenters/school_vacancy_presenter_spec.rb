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

  describe 'get_more_info_clicks' do
    let(:vacancy) { create(:vacancy, total_get_more_info_clicks: get_more_info_clicks) }

    context 'when get more info clicks are present' do
      let(:get_more_info_clicks) { 100 }

      it 'returns the number' do
        expect(presenter.get_more_info_clicks).to eq(get_more_info_clicks)
      end
    end

    context 'when get more info clicks are not present' do
      let(:get_more_info_clicks) { nil }

      it 'returns zero' do
        expect(presenter.get_more_info_clicks).to eq(0)
      end
    end
  end
end