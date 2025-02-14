require "rails_helper"

RSpec.describe "A visitor to the website can access the support links" do
  scenario "the privacy policy" do
    visit root_path

    privacy_notice_link = find_link("Privacy policy")
    expect(privacy_notice_link[:href]).to eq("https://www.gov.uk/government/publications/privacy-information-education-providers-workforce-including-teachers/privacy-information-education-providers-workforce-including-teachers")
  end

  scenario "the terms and conditions" do
    visit root_path
    click_on "Terms and conditions"
    expect(page).to have_content(/terms and conditions/i)
    expect(page).to have_content(/unacceptable use/i)
  end

  scenario "the accessibility statement" do
    visit root_path
    click_on "Accessibility"

    expect(page).to have_content(/Accessibility statement/i)
  end

  scenario "the savings methodology" do
    visit root_path
    click_on "Savings methodology"

    expect(page).to have_content(/Savings methodology/i)
  end
end
