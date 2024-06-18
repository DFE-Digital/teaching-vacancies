require "rails_helper"

RSpec.describe "Viewing a single published vacancy" do
  let(:school) { create(:school) }

  before { visit job_path(vacancy) }

  context "when the vacancy status is published" do
    let(:vacancy) do
      create(:vacancy, :published, start_date_type: "asap", organisations: [school], job_roles: %w[ teacher headteacher deputy_headteacher assistant_headteacher head_of_year_or_phase head_of_department_or_curriculum teaching_assistant
                                                                                                    higher_level_teaching_assistant education_support sendco administration_hr_data_and_finance
                                                                                                    catering_cleaning_and_site_management it_support pastoral_health_and_welfare other_leadership other_support ])
    end

    it "jobseekers can view the vacancy" do
      verify_vacancy_show_page_details(vacancy)
    end

    context "when the publish_on date is in the future" do
      let(:vacancy) { create(:vacancy, :future_publish, organisations: [school]) }

      it "Job post with a future publish_on date are not accessible" do
        expect(page).to have_content("Page not found")
        expect(page).to have_no_content(vacancy.job_title)
      end
    end

    context "when the vacancy has expired" do
      let(:vacancy) { create(:vacancy, :expired, organisations: [school]) }

      it "shows warnings that the post has expired" do
        expect(page).to have_content("EXPIRED")
        expect(page).to have_content("This job expired on #{format_date(vacancy.expires_at, :date_only)}")
      end
    end

    context "when the vacancy has not expired" do
      it "does not show warnings that the post has expired" do
        expect(page).to have_no_content("EXPIRED")
        expect(page).to have_no_content("This job expired on #{format_date(vacancy.expires_at, :date_only)}")
      end
    end

    context "with multiple working patterns" do
      let(:vacancy) { create(:vacancy, organisations: [school], working_patterns: %w[full_time part_time]) }

      it "the page contains correct JobPosting schema.org mark up" do
        expect(page).to have_content "Full time"
        expect(page).to have_content "part time"
        expect(script_tag_content(wrapper_class: ".jobref"))
          .to eq(vacancy_json_ld(VacancyPresenter.new(vacancy)).to_json)
      end
    end

    context "with supporting documents attached" do
      let(:vacancy) { create(:vacancy, :published, :with_supporting_documents, organisations: [school]) }

      it "can see the supporting documents section" do
        expect(page).to have_content(I18n.t("publishers.vacancies.steps.documents"))
        expect(page).to have_content(vacancy.supporting_documents.first.filename)
      end
    end

    context "when there is an application link set" do
      let(:vacancy) { create(:vacancy, :no_tv_applications, organisations: [school]) }

      it "a jobseeker can click on the application link" do
        click_on I18n.t("jobs.apply")

        expect(page.current_url).to eq vacancy.application_link
      end
    end

    context "meta tags" do
      include ActionView::Helpers::SanitizeHelper

      it "the vacancy's meta data are rendered correctly" do
        visit job_path(vacancy)

        expect(page.find('meta[name="description"]', visible: false)["content"])
          .to eq(I18n.t("vacancies.show.page_description", job_title: vacancy.job_title,
                                                           organisation: vacancy.organisation_name,
                                                           deadline: format_date(vacancy.expires_at, :date_only_shorthand)))
      end

      it "the vacancy's open graph meta data are rendered correctly" do
        visit job_path(vacancy)

        expect(page.find('meta[property="og:description"]', visible: false)["content"])
          .to eq(I18n.t("vacancies.show.page_description", job_title: vacancy.job_title,
                                                           organisation: vacancy.organisation_name,
                                                           deadline: format_date(vacancy.expires_at, :date_only_shorthand)))
      end
    end

    it "jobseeker sees a tag on jobs that allow to apply through Teaching Vacancies" do
      visit job_path(vacancy)
      expect(page).to have_css("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    end

    it "jobseeker does not see a tag on jobs that don't allow to apply through Teaching Vacancies" do
      vacancy_without_apply = create(:vacancy, :published, :no_tv_applications, organisations: [school])

      visit job_path(vacancy_without_apply)
      expect(page).to have_no_css("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    end

    context "with similar jobs listed" do
      let(:similar_job_tv_application) { create(:vacancy, :published, organisations: [school]) }
      let(:similar_job_no_tv_application) { create(:vacancy, :published, :no_tv_applications, organisations: [school]) }
      let(:similar_jobs_stub) do
        instance_double(Search::SimilarJobs, similar_jobs: [similar_job_tv_application, similar_job_no_tv_application])
      end

      before do
        allow(Search::SimilarJobs).to receive(:new).with(vacancy).and_return(similar_jobs_stub)
      end

      it "jobseeker sees similar jobs to the vacancy listing" do
        visit job_path(vacancy)
        within(".similar-jobs") do
          expect(page).to have_link(similar_job_tv_application.job_title, href: job_path(similar_job_tv_application))
          expect(page).to have_link(similar_job_no_tv_application.job_title, href: job_path(similar_job_no_tv_application))
        end
      end

      it "jobseeker sees a tag on similar jobs that allow to apply through Teaching Vacancies" do
        visit job_path(vacancy)
        within(".similar-jobs") do
          expect(page.find("p", text: similar_job_tv_application.job_title))
            .to have_sibling("p", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
          expect(page.find("p", text: similar_job_no_tv_application.job_title))
            .to have_no_sibling("p", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
        end
      end
    end
  end

  context "when the vacancy status is draft" do
    let(:vacancy) { create(:vacancy, :draft, organisations: [school]) }

    it "jobseekers cannot view the vacancy" do
      expect(page).to have_content("Page not found")
      expect(page).to have_no_content(vacancy.job_title)
    end
  end
end
