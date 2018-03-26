require 'rails_helper'

RSpec.feature 'Hiring staff can only see their school' do
  let(:school) { create(:school) }

  context 'when the session is connected to a Benwick school' do
    include_context 'when authenticated as a member of hiring staff',
                    stub_basic_auth_env: true

    scenario 'school page can be viewed' do
      school = create(:school)

      visit school_path(school.id)

      expect(page).to have_content(school.name)
    end
  end

  context 'when the log in is NOT connected to a Benwick school' do
    scenario 'returns the basic auth error' do
      create(:school)

      visit school_path(school.id)

      expect(page).to have_content('HTTP Basic: Access denied.')
    end
  end
end
