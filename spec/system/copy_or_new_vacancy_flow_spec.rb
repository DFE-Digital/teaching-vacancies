require "rails_helper"

RSpec.describe "Copy-or-new vacancy flow" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  let(:vacancy_count) { 20 }
  let(:original_vacancy) { school.vacancies.first }

  before do
    (vacancy_count - school.vacancies.published.count).times do
      create_published_vacancy(organisations: [school])
    end

    login_publisher(publisher:, organisation: school)
  end

  scenario "Publishers are directed into either copy or new vacancy flows" do
    visit organisation_path
    click_on "Create a job listing"
    expect(page).to have_content("What do you want to do?")

    choose "Start with a blank template"
    click_on "Continue"
    expect(page).to have_content("Step 1 of 9")

    click_on "Cancel and return to manage jobs"
    click_on "Create a job listing"

    choose "Copy an existing job listing"
    click_on "Continue"
    expect(page).to have_content("Select a job to copy")
    expect(page).to have_css(".govuk-radios__input", count: vacancy_count)

    page.first("label", text: original_vacancy.job_title).click
    click_on "Continue"

    choose "Today"

    closing_date_fieldset = page
      .find("h3", text: "Closing date")
      .ancestor("fieldset")

    date = 2.months.from_now.to_date
    within closing_date_fieldset do
      fill_in "Day", with: date.day
      fill_in "Month", with: date.month
      fill_in "Year", with: date.year
    end

    choose "7am"

    click_on "Continue"
    expect(page).to have_content("Review the job listing")

    click_on "Confirm and submit job"
    expect(page).to have_link("Create another job listing", href: create_or_copy_organisation_jobs_path)
  end

  context "if there's more than 20 published vacancies", js: true do
    let(:vacancy_count) { 21 }

    scenario "an autocomplete box is used to find the vacancy for copying" do
      visit organisation_path
      click_on "Create a job listing"
      expect(page).to have_content("What do you want to do?")

      page.find("label", text: "Copy an existing job listing").click
      click_on "Continue"

      fill_in "Select a job to copy", with: original_vacancy.job_title[0..5]

      page.first(".job-title", text: original_vacancy.job_title).ancestor("li").click
      click_on "Continue"

      expect(page).to have_text("Copy #{original_vacancy.job_title}")
    end

    context "but javascript is disabled", js: false do
      scenario "it shows the list of radio buttons" do
        visit organisation_path
        click_on "Create a job listing"
        choose "Copy an existing job listing"
        click_on "Continue"

        expect(page).to have_content("Select a job to copy")
        expect(page).to have_css(".govuk-radios__input", count: vacancy_count)
      end
    end
  end

  context "if there are no published vacancies" do
    let(:vacancy_count) { 0 }

    scenario "publishers are sent straight to the 'create new' path" do
      visit organisation_path
      click_on "Create a job listing"
      expect(page).to have_content("Step 1 of 9")
    end
  end
end
