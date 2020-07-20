require 'rails_helper'

RSpec.describe 'pages/home/_signin.html.haml' do
  context 'if session is authenticated' do
    before do
      allow(view).to receive(:authenticated?).and_return(true)
      school = create(:school, name: 'Salisbury School')
      allow(view).to receive(:current_organisation) { school }
      render
    end

    it 'should display the manage schools workflow' do
      expect(render).to have_css('.manage-vacancies')
    end
  end

  context 'if session is not authenticated' do
    before do
      allow(view).to receive(:authenticated?).and_return(false)
      render
    end

    it 'should display the regular signin workflow' do
      expect(render).to have_css('.identifications-button')
    end
  end
end
