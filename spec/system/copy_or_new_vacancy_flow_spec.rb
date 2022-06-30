require "rails_helper"

RSpec.describe "Copy-or-new vacancy flow" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  let(:original_vacancy) { school.vacancies.first }

  before { login_publisher(publisher: publisher, organisation: school) }

  context "when there are published vacancies" do
    before { create_published_vacancy(organisations: [school]) }

    scenario "publishers are directed into either copy or new vacancy flows" do
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
    end

    context "when there's less than 5 published vacancies" do
      scenario "the publisher can select a vacancy to copy from a list of radio options" do
        visit organisation_path
        click_on "Create a job listing"
        choose "Copy an existing job listing"
        click_on "Continue"
        expect(page).to have_content("Select a job to copy")
        expect(page).to have_css(".govuk-radios__input", count: school.vacancies.published.count)

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
    end

    context "when there's 5 or more published vacancies", js: true do
      before { 4.times { create_published_vacancy(organisations: [school]) } }

      scenario "the publisher can search for the vacancy they wish to copy" do
        visit organisation_path
        click_on "Create a job listing"
        expect(page).to have_content("What do you want to do?")

        page.find("label", text: "Copy an existing job listing").click
        click_on "Continue"

        fill_in class: "govuk-input", with: original_vacancy.job_title[0..5]
        page.find("label.govuk-radios__label", text: original_vacancy.job_title, match: :first).click
        click_on "Continue"

        expect(page).to have_text("Copy #{original_vacancy.job_title}")
      end

      context "when javascript is disabled", js: false do
        scenario "it shows the list of radio buttons" do
          visit organisation_path
          click_on "Create a job listing"
          choose "Copy an existing job listing"
          click_on "Continue"

          expect(page).to have_content("Select a job to copy")
          expect(page).to have_css(".govuk-radios__input", count: school.vacancies.published.count)
        end
      end
    end
  end

  context "when there are no published vacancies" do
    scenario "publishers are sent straight to the 'create new' path" do
      visit organisation_path
      click_on "Create a job listing"
      expect(page).to have_content("Step 1 of 9")
    end
  end
end
