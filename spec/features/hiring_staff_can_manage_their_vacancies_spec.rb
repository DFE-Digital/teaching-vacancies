require 'rails_helper'

RSpec.feature 'Hiring staff can manage vacancies from a link on home page' do
  let(:school) { create(:school) }

  scenario 'as an authenticated user' do
    stub_hiring_staff_auth(urn: school.urn)

    visit root_path

    within('div.manage-vacancies') do
      click_on(I18n.t('pages.home.signed_in.manage_link'))
    end

    expect(find('h1')).to have_content(I18n.t('schools.jobs.index', school: school.name))
  end
end
