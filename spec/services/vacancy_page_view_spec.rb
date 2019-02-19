require 'rails_helper'

RSpec.describe VacancyPageView do
  subject(:vacancy_page_view) { described_class.new(vacancy) }

  describe '#track' do
    let(:page_view_counter) { spy(increment: true) }
    let(:vacancy) { double(:vacancy, page_view_counter: page_view_counter) }

    it 'increments the page view counter' do
      vacancy_page_view.track

      expect(page_view_counter).to have_received(:increment)
    end
  end

  describe '#persist!' do
    let(:page_view_counter) { spy(to_i: 30) }
    let(:vacancy) { instance_spy('Vacancy', total_pageviews: 2, page_view_counter: page_view_counter) }

    it 'updates the total page views' do
      vacancy_page_view.persist!

      expect(vacancy).to have_received(:total_pageviews=).with 32
      expect(vacancy).to have_received(:save)
    end

    context 'the page views are persisted' do
      it 'resets the page view counter' do
        allow(vacancy).to receive(:total_pageviews=)
        allow(vacancy).to receive(:save).and_return(true)

        vacancy_page_view.persist!

        expect(page_view_counter).to have_received(:reset)
      end
    end

    context 'the page views are not persisted' do
      it 'does not reset the page view counter' do
        allow(vacancy).to receive(:total_pageviews=)
        allow(vacancy).to receive(:save).and_return(false)

        vacancy_page_view.persist!

        expect(page_view_counter).not_to have_received(:reset)
      end
    end
  end
end
