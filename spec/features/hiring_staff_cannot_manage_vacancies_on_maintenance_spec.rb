require 'rails_helper'

RSpec.feature 'Hiring staff cannot manage vacancies on maintenance' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  context 'when the read-only feature flag is set to true' do
    before do
      allow(ReadOnlyFeature).to receive(:enabled?).and_return(true)

      stub_hiring_staff_auth(urn: school.urn, session_id: session_id)

      visit school_path
    end

    it 'redirects to home page' do
      expect(current_path).to eq(root_path)
    end

    it 'shows maintainance message' do
      expect(page).to have_text(I18n.t('pages.home.read_only.title'))
    end
  end

  context 'when the read-only feature flag is set to false' do
    before do
      allow(ReadOnlyFeature).to receive(:enabled?).and_return(false)

      stub_hiring_staff_auth(urn: school.urn, session_id: session_id)

      visit school_path
    end

    it 'redirects to school page' do
      expect(current_path).to eq(school_path)
    end
  end
end
