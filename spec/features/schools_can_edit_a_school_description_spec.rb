require 'rails_helper'
RSpec.feature 'Editing a School’s description' do
  before do
    @school = create(:school, name: 'Salisbury school', description: 'We are a good school')
  end

  scenario 'updating a description' do
    visit school_path(@school.urn)

    expect(page).to have_content('Salisbury school')
    expect(page).to have_content('We are a good school')

    click_on 'Change description'
    fill_in 'Description', with: 'Our school prides itself on excellence.'
    click_on 'Save'

    expect(page).to have_content('Our school prides itself on excellence.')
  end

  scenario 'removing a description' do
    visit school_path(@school.urn)

    expect(page).to have_content('Salisbury school')
    expect(page).to have_content('We are a good school')

    click_on 'Change description'
    fill_in 'Description', with: ''
    click_on 'Save'

    expect(page).to have_content('Description Not provided')
  end
end