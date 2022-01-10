require "rails_helper"

RSpec.describe "Copying a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  let!(:original_vacancy) { create_published_vacancy(organisations: [school]) }

  before { login_publisher(publisher:, organisation: school) }

  describe "Cancelling the copy" do
    scenario "a copy can be cancelled using the cancel copy back link" do
      new_vacancy = original_vacancy.dup
      new_vacancy.job_title = "A new job title"

      visit organisation_path
      click_on original_vacancy.job_title
      click_on I18n.t("buttons.copy_listing")

      fill_in_copy_vacancy_form_fields(new_vacancy)

      click_on I18n.t("buttons.cancel_copy")

      expect(page.current_path).to eq(organisation_path)
      expect(page).not_to have_content("A new job title")
    end

    scenario "a copy can be cancelled using the cancel copy link" do
      new_vacancy = original_vacancy.dup
      new_vacancy.job_title = "A new job title"

      visit organisation_path
      click_on original_vacancy.job_title
      click_on I18n.t("buttons.copy_listing")

      fill_in_copy_vacancy_form_fields(new_vacancy)

      click_on(I18n.t("buttons.cancel_copy"), class: "govuk-link")

      expect(page.current_path).to eq(organisation_path)
      expect(page).not_to have_content("A new job title")
    end
  end

  scenario "a job can be successfully copied and published" do
    new_vacancy = original_vacancy.dup
    new_vacancy.job_title = "A new job title"
    new_vacancy.starts_on = 35.days.from_now
    new_vacancy.publish_on = 0.days.from_now
    new_vacancy.expires_at = new_vacancy.expires_at = 30.days.from_now.change(hour: 9, minute: 0)

    visit organisation_path
    click_on original_vacancy.job_title
    click_on I18n.t("buttons.copy_listing")

    within("h1.govuk-heading-m") do
      expect(page).to have_content(I18n.t("jobs.copy_job_title", job_title: original_vacancy.job_title))
    end

    fill_in_copy_vacancy_form_fields(new_vacancy)
    click_on I18n.t("buttons.continue")

    within("h2.govuk-heading-l") do
      expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))
    end
    click_on I18n.t("buttons.submit_job_listing")

    expect(page).to have_content(I18n.t("publishers.vacancies.summary.success"))
  end

  context "when the original job is now invalid" do
    let!(:original_vacancy) do
      create_published_vacancy(about_school: nil, job_location: "at_one_school", organisations: [school]) do |vacancy|
        vacancy.send(:set_slug)
      end
    end

    scenario "the job can be successfully copied but not published until valid" do
      visit organisation_path
      click_on original_vacancy.job_title
      click_on I18n.t("buttons.copy_listing")

      new_vacancy = original_vacancy.dup
      new_vacancy.job_title = "A new job title"
      new_vacancy.starts_on = 35.days.from_now
      new_vacancy.publish_on = 0.days.from_now
      new_vacancy.expires_at = 30.days.from_now.change(hour: 9, minute: 0)

      within("h1.govuk-heading-m") do
        expect(page).to have_content(I18n.t("jobs.copy_job_title", job_title: original_vacancy.job_title))
      end

      fill_in_copy_vacancy_form_fields(new_vacancy)
      click_on I18n.t("buttons.continue")

      expect(page).to have_content(I18n.t("job_summary_errors.about_school.blank", organisation: "school"))

      new_persisted_vacancy = Vacancy.find_by(job_title: "A new job title")
      visit organisation_job_build_path(new_persisted_vacancy.id, :job_summary)

      fill_in "publishers_job_listing_job_summary_form[about_school]", with: "Some description about the school"
      click_on I18n.t("buttons.update_job")

      within("h2.govuk-heading-l") do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))
      end
      expect(page).to have_content("Some description about the school")

      click_on I18n.t("buttons.submit_job_listing")

      expect(page).to have_content(I18n.t("publishers.vacancies.summary.success"))
    end
  end

  context "when the original job is pending/scheduled/future_publish" do
    let!(:original_vacancy) { create(:vacancy, :future_publish, organisations: [school]) }

    scenario "a job can be successfully copied" do
      visit organisation_path
      click_on I18n.t("publishers.vacancies_component.pending.tab_heading")
      click_on original_vacancy.job_title
      click_on I18n.t("buttons.copy_listing")

      within("h1.govuk-heading-m") do
        expect(page).to have_content(I18n.t("jobs.copy_job_title", job_title: original_vacancy.job_title))
      end

      click_on I18n.t("buttons.continue")

      within("h2.govuk-heading-l") do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))
      end
    end
  end

  context "when the original job has expired" do
    let!(:original_vacancy) { create(:vacancy, :expired, organisations: [school]) }

    scenario "a job can be successfully copied" do
      new_vacancy = original_vacancy.dup
      new_vacancy.job_title = "A new job title"
      new_vacancy.starts_on = 35.days.from_now
      new_vacancy.publish_on = 0.days.from_now
      new_vacancy.expires_at = 30.days.from_now.change(hour: 9, minute: 0)

      visit organisation_path
      click_on I18n.t("publishers.vacancies_component.expired.tab_heading")
      click_on original_vacancy.job_title
      click_on I18n.t("buttons.copy_listing")

      within("h1.govuk-heading-m") do
        expect(page).to have_content(I18n.t("jobs.copy_job_title", job_title: original_vacancy.job_title))
      end

      fill_in_copy_vacancy_form_fields(new_vacancy)
      click_on I18n.t("buttons.continue")

      within("h2.govuk-heading-l") do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.review_heading"))
      end
    end
  end

  context "when a copied job has an invalid date" do
    let!(:original_vacancy) { create_published_vacancy(organisations: [school]) }

    scenario "it shows a validation error" do
      new_vacancy = original_vacancy.dup
      new_vacancy.job_title = "A new job title"
      new_vacancy.publish_on = 0.days.from_now
      new_vacancy.expires_at = 1.day.from_now

      visit organisation_path
      click_on original_vacancy.job_title
      click_on I18n.t("buttons.copy_listing")

      within("h1.govuk-heading-m") do
        expect(page).to have_content(I18n.t("jobs.copy_job_title", job_title: original_vacancy.job_title))
      end

      fill_in_copy_vacancy_form_fields(new_vacancy)
      fill_in "publishers_job_listing_copy_vacancy_form[expires_at(2i)]", with: "090"

      click_on I18n.t("buttons.continue")
      expect(page).to have_content(I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.invalid"))
    end
  end

  describe "validations" do
    let!(:original_vacancy) { create_published_vacancy(organisations: [school]) }
    let(:new_vacancy) { build(:vacancy, original_vacancy.attributes.merge(new_attributes)) }

    before do
      visit organisation_path
      click_on original_vacancy.job_title
      click_on I18n.t("buttons.copy_listing")

      expect(page).to have_content(I18n.t("jobs.copy_job_title", job_title: original_vacancy.job_title))

      fill_in_copy_vacancy_form_fields(new_vacancy)
      click_on I18n.t("buttons.continue")
    end

    context "when publish on is blank" do
      let(:new_attributes) { { publish_on: nil } }

      it "shows an error" do
        expect(page).to have_content(I18n.t("activerecord.errors.models.vacancy.attributes.publish_on.blank"))
      end
    end

    context "when publish on date is in the past" do
      let(:new_attributes) { { publish_on: 1.day.ago } }

      it "shows an error" do
        expect(page).to have_content(I18n.t("activerecord.errors.models.vacancy.attributes.publish_on.on_or_after"))
      end
    end

    context "when expires at is blank" do
      let(:new_attributes) { { expires_at: nil } }

      it "shows an error" do
        expect(page).to have_content(I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.blank"))
      end
    end

    context "when job title is blank" do
      let(:new_attributes) { { job_title: nil } }

      it "shows an error" do
        expect(page).to have_content(I18n.t("activerecord.errors.models.vacancy.attributes.job_title.blank"))
      end
    end
  end
end
