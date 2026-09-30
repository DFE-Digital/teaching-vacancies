require "rails_helper"

RSpec.describe "A visitor to the website can access the support links" do
  before do
    visit root_path
  end

  scenario "the privacy policy and accesibility statement external links", :aggregate_failures do
    expect(page).to have_link("Privacy policy", href: "https://www.gov.uk/government/publications/privacy-information-education-providers-workforce-including-teachers/privacy-information-education-providers-workforce-including-teachers")
    expect(page).to have_link("Accessibility", href: "https://accessibility-statements.education.gov.uk/statement/45")
  end

  scenario "the terms and conditions" do
    click_on "Terms and conditions"
    expect(page).to have_content(/terms and conditions/i)
    expect(page).to have_content(/unacceptable use/i)
  end

  scenario "the savings methodology" do
    click_on "Savings methodology"

    expect(page).to have_content(/Savings methodology/i)
  end
end
