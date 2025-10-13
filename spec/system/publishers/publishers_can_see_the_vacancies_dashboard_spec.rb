require "rails_helper"

RSpec.describe "Publishers can see the vacancies dashboard" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school) }

  before do
    login_publisher(publisher: publisher, organisation: school)
    visit organisation_jobs_with_type_path
  end

  after { logout }

  scenario "school" do
    vacancy = create(:vacancy, organisations: [school])

    visit current_path

    click_on(vacancy.job_title)

    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.skills_and_experience)
  end

  it "passes a11y", :a11y do
    expect(page).to be_axe_clean
  end

  context "viewing the lists of jobs on the school page" do
    let!(:published_vacancy) { create(:vacancy, organisations: [school]) }
    let!(:draft_vacancy) { create(:draft_vacancy, organisations: [school]) }
    let!(:pending_vacancy) { create(:vacancy, :future_publish, organisations: [school]) }
    let!(:expired_vacancy) do
      create(:vacancy, :expired, organisations: [school])
    end

    scenario "jobs are split into sections" do
      create_list(:vacancy, 5, organisations: [school])

      visit current_path

      expect(page).to have_content(I18n.t("jobs.dashboard.published.tab_heading"))
      expect(page).to have_content(I18n.t("jobs.dashboard.draft.tab_heading"))
      expect(page).to have_content(I18n.t("jobs.dashboard.pending.tab_heading"))
      expect(page).to have_content(I18n.t("jobs.dashboard.expired.tab_heading"))
      expect(page).to have_content(I18n.t("jobs.dashboard.awaiting_feedback.tab_heading"))
    end

    scenario "with published vacancies" do
      within(".dashboard-component") do
        click_on(I18n.t("jobs.dashboard.published.tab_heading"))
      end

      expect(page).to have_content(published_vacancy.job_title)
      expect(page).to have_css(".govuk-summary-list", count: 1)
    end

    scenario "with draft vacancies" do
      within(".dashboard-component") do
        click_on(I18n.t("jobs.dashboard.draft.tab_heading"))
      end

      expect(page).to have_content(I18n.t("jobs.manage.draft.time_created"))
      expect(page).to have_content(format_date(draft_vacancy.created_at.to_date))
      expect(page).to have_content(format_date(draft_vacancy.updated_at.to_date))
      expect(page).to have_content(draft_vacancy.job_title)
      expect(page).to have_css(".govuk-summary-list", count: 1)
    end

    scenario "with pending vacancies" do
      within(".dashboard-component") do
        click_on(I18n.t("jobs.dashboard.pending.tab_heading"))
      end

      expect(page).to have_content(I18n.t("jobs.publication_date"))
      expect(page).to have_content(pending_vacancy.job_title)
      expect(page).to have_content(format_date(pending_vacancy.publish_on))
      expect(page).to have_content(format_date(pending_vacancy.expires_at.to_date))
      expect(page).to have_css(".govuk-summary-list", count: 1)
    end

    scenario "with expired vacancies" do
      within(".dashboard-component") do
        click_on(I18n.t("jobs.dashboard.expired.tab_heading"))
      end

      expect(page).to have_content(expired_vacancy.job_title)
      expect(page).to have_content(format_date(expired_vacancy.expires_at.to_date))
      expect(page).to have_content(format_date(expired_vacancy.publish_on))
      expect(page).to have_css(".govuk-summary-list", count: 1)
    end

    context "when a draft vacancy has been updated" do
      let!(:draft_vacancy) { create(:draft_vacancy, organisations: [school], created_at: 3.days.ago, updated_at: 1.day.ago) }

      scenario "shows the last updated at" do
        visit current_path

        within(".dashboard-component") do
          click_on(I18n.t("jobs.dashboard.draft.tab_heading"))
        end

        expect(page).to have_content(format_date(draft_vacancy.created_at.to_date))
        expect(page).to have_content(format_date(draft_vacancy.updated_at.to_date))
      end
    end
  end
end
