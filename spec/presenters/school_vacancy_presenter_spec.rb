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
end