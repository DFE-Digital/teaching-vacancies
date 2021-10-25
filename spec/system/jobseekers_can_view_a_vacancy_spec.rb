require "rails_helper"

RSpec.describe "Viewing a single published vacancy" do
  let(:school) { create(:school) }

  before { visit job_path(vacancy) }

  context "when the vacancy status is published" do
    let(:vacancy) { create(:vacancy, :published, organisations: [school]) }

    scenario "jobseekers can view the vacancy" do
      verify_vacancy_show_page_details(vacancy)
    end

    context "when the publish_on date is in the future" do
      let(:vacancy) { create(:vacancy, :future_publish, organisations: [school]) }

      scenario "Job post with a future publish_on date are not accessible" do
        expect(page).to have_content("Page not found")
        expect(page).to_not have_content(vacancy.job_title)
      end
    end

    context "when the vacancy has expired" do
      let(:vacancy) { create(:vacancy, :expired, organisations: [school]) }

      scenario "it shows warnings that the post has expired" do
        expect(page).to have_content("EXPIRED")
        expect(page).to have_content("This job expired on #{format_date(vacancy.expires_at, :date_only)}")
      end
    end

    context "when the vacancy has not expired" do
      scenario "it does not show warnings that the post has expired" do
        expect(page).not_to have_content("EXPIRED")
        expect(page).not_to have_content("This job expired on #{format_date(vacancy.expires_at, :date_only)}")
      end
    end

    context "with multiple working patterns" do
      let(:vacancy) { create(:vacancy, organisations: [school], working_patterns: %w[full_time part_time]) }

      scenario "the page contains correct JobPosting schema.org mark up" do
        expect(script_tag_content(wrapper_class: ".jobref"))
          .to eq(vacancy_json_ld(VacancyPresenter.new(vacancy)).to_json)
      end
    end

    context "with supporting documents attached" do
      let(:vacancy) { create(:vacancy, :published, :with_supporting_documents, organisations: [school]) }

      scenario "can see the supporting documents section" do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.documents"))
        expect(page).to have_content(vacancy.supporting_documents.first.filename)
      end
    end

    context "when there is an application link set" do
      let(:vacancy) { create(:vacancy, :no_tv_applications, organisations: [school]) }

      scenario "a jobseeker can click on the application link" do
        click_on I18n.t("jobs.apply")

        expect(page.current_url).to eq vacancy.application_link
      end
    end

    context "meta tags" do
      include ActionView::Helpers::SanitizeHelper

      scenario "the vacancy's meta data are rendered correctly" do
        visit job_path(vacancy)

        expect(page.find('meta[name="description"]', visible: false)["content"])
          .to eq(I18n.t("vacancies.show.page_description", job_title: vacancy.job_title,
                                                           organisation: vacancy.parent_organisation.name,
                                                           deadline: format_date(vacancy.expires_at, :date_only_shorthand)))
      end

      scenario "the vacancy's open graph meta data are rendered correctly" do
        visit job_path(vacancy)

        expect(page.find('meta[property="og:description"]', visible: false)["content"])
          .to eq(I18n.t("vacancies.show.page_description", job_title: vacancy.job_title,
                                                           organisation: vacancy.parent_organisation.name,
                                                           deadline: format_date(vacancy.expires_at, :date_only_shorthand)))
      end
    end
  end

  context "when the vacancy status is draft" do
    let(:vacancy) { create(:vacancy, :draft, organisations: [school]) }

    scenario "jobseekers cannot view the vacancy" do
      expect(page).to have_content("Page not found")
      expect(page).to_not have_content(vacancy.job_title)
    end
  end
end
