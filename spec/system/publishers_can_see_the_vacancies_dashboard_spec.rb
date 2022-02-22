require "rails_helper"

RSpec.describe "Publishers can see the vacancies dashboard" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  scenario "school" do
    login_publisher(publisher: publisher, organisation: school)
    vacancy = create(:vacancy, status: "published", organisations: [school])

    visit organisation_path

    click_on(vacancy.job_title)

    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.job_advert)
  end

  context "viewing the lists of jobs on the school page" do
    let!(:published_vacancy) { create(:vacancy, :published, organisations: [school]) }
    let!(:draft_vacancy) { create(:vacancy, :draft, organisations: [school]) }
    let!(:pending_vacancy) { create(:vacancy, :future_publish, organisations: [school]) }
    let!(:expired_vacancy) do
      expired_vacancy = build(:vacancy, :expired, organisations: [school])
      expired_vacancy.save(validate: false)
      expired_vacancy
    end

    before { login_publisher(publisher: publisher, organisation: school) }

    scenario "jobs are split into sections" do
      create_list(:vacancy, 5, :published, organisations: [school])

      visit organisation_path

      expect(page).to have_content(I18n.t("publishers.vacancies_component.published.tab_heading"))
      expect(page).to have_content(I18n.t("publishers.vacancies_component.draft.tab_heading"))
      expect(page).to have_content(I18n.t("publishers.vacancies_component.pending.tab_heading"))
      expect(page).to have_content(I18n.t("publishers.vacancies_component.expired.tab_heading"))
      expect(page).to have_content(I18n.t("publishers.vacancies_component.awaiting_feedback.tab_heading"))
    end

    scenario "with published vacancies" do
      visit organisation_path

      within(".tabs-component-navigation__list") do
        click_on(I18n.t("publishers.vacancies_component.published.tab_heading"))
      end

      within(".vacancies-component__content") do
        expect(page).to have_content(published_vacancy.job_title)
        expect(page).to have_css(".card-component", count: 1)
      end
    end

    scenario "with draft vacancies" do
      visit organisation_path

      within(".tabs-component-navigation__list") do
        click_on(I18n.t("publishers.vacancies_component.draft.tab_heading"))
      end

      within(".vacancies-component__content") do
        expect(page).to have_content(I18n.t("jobs.manage.draft.time_created"))
        expect(page).to have_content(format_date(draft_vacancy.created_at.to_date))
        expect(page).to have_content(format_date(draft_vacancy.updated_at.to_date))
        expect(page).to have_content(draft_vacancy.job_title)
        expect(page).to have_css(".card-component", count: 1)
      end
    end

    scenario "with pending vacancies" do
      visit organisation_path

      within(".tabs-component-navigation__list") do
        click_on(I18n.t("publishers.vacancies_component.pending.tab_heading"))
      end

      within(".vacancies-component__content") do
        expect(page).to have_content(I18n.t("jobs.publication_date"))
        expect(page).to have_content(pending_vacancy.job_title)
        expect(page).to have_content(format_date(pending_vacancy.publish_on))
        expect(page).to have_content(format_date(pending_vacancy.expires_at.to_date))
        expect(page).to have_css(".card-component", count: 1)
      end
    end

    scenario "with expired vacancies" do
      visit organisation_path

      within(".tabs-component-navigation__list") do
        click_on(I18n.t("publishers.vacancies_component.expired.tab_heading"))
      end

      within(".vacancies-component__content") do
        expect(page).to have_content(expired_vacancy.job_title)
        expect(page).to have_content(format_date(expired_vacancy.expires_at.to_date))
        expect(page).to have_content(format_date(expired_vacancy.publish_on))
        expect(page).to have_css(".card-component", count: 1)
      end
    end

    context "when a draft vacancy has been updated" do
      let!(:draft_vacancy) { create(:vacancy, :draft, organisations: [school], created_at: 3.days.ago, updated_at: 1.day.ago) }

      scenario "shows the last updated at" do
        draft_vacancy
        visit organisation_path

        within(".tabs-component-navigation__list") do
          click_on(I18n.t("publishers.vacancies_component.draft.tab_heading"))
        end

        within(".vacancies-component__content") do
          expect(page).to have_content(format_date(draft_vacancy.created_at.to_date))
          expect(page).to have_content(format_date(draft_vacancy.updated_at.to_date))
        end
      end
    end
  end
end
