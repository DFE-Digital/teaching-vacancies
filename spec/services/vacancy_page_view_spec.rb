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
end
