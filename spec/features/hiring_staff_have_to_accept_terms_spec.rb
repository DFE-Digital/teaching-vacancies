require 'rails_helper'

RSpec.feature 'Hiring staff accepts terms and conditions' do
  let(:school) { create(:school) }
  before do
    stub_hiring_staff_auth(urn: school.urn, session_id: user.oid)
  end

  context 'the user has not accepted the terms and conditions' do
    let(:user) { create(:user, accepted_terms_at: nil) }

    scenario 'they will see the terms and conditions' do
      visit school_path

      expect(page).to have_content('Terms and Conditions for Schools')
    end
  end

  context 'the user has accepted the terms and conditions' do
    let(:user) { create(:user, accepted_terms_at: Time.zone.now) }

    scenario 'they will not see the terms and conditions' do
      visit school_path

      expect(page).not_to have_content('Terms and Conditions for Schools')
    end
  end
end
