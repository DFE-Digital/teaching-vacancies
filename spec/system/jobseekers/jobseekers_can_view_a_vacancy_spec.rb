require "rails_helper"

RSpec.describe "Viewing a single published vacancy" do
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
      expect(page).to be_axe_clean
    end

    scenario "jobseekers can view the vacancy" do
      verify_vacancy_show_page_details(vacancy)
    end

    context "with supporting documents attached" do
      let(:vacancy) { create(:vacancy, :with_supporting_documents, organisations: [school]) }

      scenario "can see the supporting documents section" do
        expect(page).to have_content(I18n.t("jobs.additional_documents"))
        expect(page).to have_content(vacancy.supporting_documents.first.filename)
      end
    end

    context "meta tags" do
      include ActionView::Helpers::SanitizeHelper

      scenario "the vacancy's meta data are rendered correctly" do
        expect(page.find('meta[name="description"]', visible: false)["content"])
          .to eq(I18n.t("vacancies.vacancy_banner.page_description", job_title: vacancy.job_title,
                                                                     organisation: vacancy.organisation_name,
                                                                     deadline: format_date(vacancy.expires_at, :date_only_shorthand)))
      end

      scenario "the vacancy's open graph meta data are rendered correctly" do
        expect(page.find('meta[property="og:description"]', visible: false)["content"])
          .to eq(I18n.t("vacancies.vacancy_banner.page_description", job_title: vacancy.job_title,
                                                                     organisation: vacancy.organisation_name,
                                                                     deadline: format_date(vacancy.expires_at, :date_only_shorthand)))
      end
    end

    context "with similar jobs listed" do
      let(:similar_job_tv_application) { create(:vacancy, organisations: [school]) }
      let(:similar_job_no_tv_application) { create(:vacancy, :apply_via_website, organisations: [school]) }
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
end
