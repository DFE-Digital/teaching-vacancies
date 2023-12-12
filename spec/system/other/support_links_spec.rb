require "rails_helper"

RSpec.describe "A visitor to the website can access the support links" do
  scenario "the privacy policy" do
    visit root_path
    click_on "Privacy policy"

    expect(page).to have_content("Privacy Notice: Teaching Vacancies")
  end

  scenario "the terms and conditions" do
    visit root_path
    click_on "Terms and Conditions"
    expect(page).to have_content(/terms and conditions/i)
    expect(page).to have_content(/unacceptable use/i)
  end

  scenario "the accessibility statement" do
    visit root_path
    click_on "Accessibility"

    expect(page).to have_content(/Accessibility statement for Teaching Vacancies/i)
  end
end
