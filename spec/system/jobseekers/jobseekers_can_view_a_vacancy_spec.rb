require "rails_helper"

RSpec.describe "Viewing a single published vacancy" do
  include ActiveJob::TestHelper

  let(:school) { create(:school) }

  before do
    visit job_path(vacancy)
  end

  context "when the vacancy status is published" do
    let(:vacancy) do
      create(:vacancy, start_date_type: "asap", organisations: [school], job_roles: %w[ teacher
                                                                                        headteacher
                                                                                        deputy_headteacher
                                                                                        assistant_headteacher
                                                                                        head_of_year_or_phase
                                                                                        head_of_department_or_curriculum
                                                                                        teaching_assistant
                                                                                        higher_level_teaching_assistant
                                                                                        education_support
                                                                                        sendco
                                                                                        administration_hr_data_and_finance
                                                                                        catering_cleaning_and_site_management
                                                                                        it_support
                                                                                        pastoral_health_and_welfare
                                                                                        other_leadership
                                                                                        other_support ])
    end

    it "passes a11y", :a11y do
      expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"
    end

    scenario "jobseekers can view the vacancy" do
      verify_vacancy_show_page_details(vacancy)
    end

    scenario "tracks the view in Redis" do
      mock_redis = MockRedis.new
      allow(Redis).to receive(:current).and_return(mock_redis)

      referrer_url = "https://example.com/some/path?utm=123"
      redis_key = "vacancy_referrer_stats:#{vacancy.id}:example.com"

      perform_enqueued_jobs do
        page.driver.header("Referer", referrer_url)
        visit job_path(vacancy)
      end
      expect(Redis.current.get(redis_key).to_i).to be > 0
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

    context "with supporting documents attached" do
      let(:vacancy) { create(:vacancy, :with_supporting_documents, organisations: [school]) }

      scenario "can see the supporting documents section" do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.documents"))
        expect(page).to have_content(vacancy.supporting_documents.first.filename)
      end
    end

    context "when there is an application link set" do
      let(:vacancy) { create(:vacancy, :no_tv_applications, organisations: [school]) }

      scenario "a jobseeker can click on the application link" do
        click_on I18n.t("jobs.view_advert.school")

        expect(page.current_url).to eq vacancy.application_link
      end
    end

    context "meta tags" do
      include ActionView::Helpers::SanitizeHelper

      scenario "the vacancy's meta data are rendered correctly" do
        expect(page.find('meta[name="description"]', visible: false)["content"])
          .to eq(I18n.t("vacancies.show.page_description", job_title: vacancy.job_title,
                                                           organisation: vacancy.organisation_name,
                                                           deadline: format_date(vacancy.expires_at, :date_only_shorthand)))
      end

      scenario "the vacancy's open graph meta data are rendered correctly" do
        expect(page.find('meta[property="og:description"]', visible: false)["content"])
          .to eq(I18n.t("vacancies.show.page_description", job_title: vacancy.job_title,
                                                           organisation: vacancy.organisation_name,
                                                           deadline: format_date(vacancy.expires_at, :date_only_shorthand)))
      end
    end

    scenario "jobseeker sees a tag on jobs that allow to apply through Teaching Vacancies" do
      expect(page).to have_css("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    end

    scenario "jobseeker does not see a tag on jobs that don't allow to apply through Teaching Vacancies" do
      vacancy_without_apply = create(:vacancy, :no_tv_applications, organisations: [school])

      visit job_path(vacancy_without_apply)
      expect(page).not_to have_css("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    end

    context "with similar jobs listed" do
      let(:similar_job_tv_application) { create(:vacancy, organisations: [school]) }
      let(:similar_job_no_tv_application) { create(:vacancy, :no_tv_applications, organisations: [school]) }
      let(:similar_jobs_stub) do
        instance_double(Search::SimilarJobs, similar_jobs: [similar_job_tv_application, similar_job_no_tv_application])
      end

      before do
        allow(Search::SimilarJobs).to receive(:new).with(vacancy).and_return(similar_jobs_stub)
        visit current_path
      end

      scenario "jobseeker sees similar jobs to the vacancy listing" do
        within(".similar-jobs") do
          expect(page).to have_link(similar_job_tv_application.job_title, href: job_path(similar_job_tv_application))
          expect(page).to have_link(similar_job_no_tv_application.job_title, href: job_path(similar_job_no_tv_application))
        end
      end

      scenario "jobseeker sees a tag on similar jobs that allow to apply through Teaching Vacancies" do
        within(".similar-jobs") do
          expect(page.find("p", text: similar_job_tv_application.job_title))
            .to have_sibling("p", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
          expect(page.find("p", text: similar_job_no_tv_application.job_title))
            .not_to have_sibling("p", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
        end
      end
    end
  end

  context "when the vacancy status is draft" do
    let(:vacancy) { create(:draft_vacancy, organisations: [school]) }

    scenario "jobseekers cannot view the vacancy" do
      expect(page).to have_content("Page not found")
      expect(page).to_not have_content(vacancy.job_title)
    end
  end
end
