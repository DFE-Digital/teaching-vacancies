require "rails_helper"

RSpec.describe "Publishers can view vacancy statastics" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }

  before do
    create(:saved_job, vacancy: vacancy)
    create(:job_application, :status_submitted, vacancy: vacancy)
    create(:job_application, :status_shortlisted, vacancy: vacancy)
    create(:job_application, :status_unsuccessful, vacancy: vacancy)
    create(:job_application, :status_withdrawn, vacancy: vacancy)

    login_publisher(publisher: publisher, organisation: organisation)
    vacancy_stats = instance_double(Publishers::VacancyStats, number_of_unique_views: 42)
    allow(Publishers::VacancyStats).to receive(:new).with(vacancy).and_return(vacancy_stats)
    visit organisation_job_statistics_path(vacancy.id)
  end

  after { logout }

  describe "job listing source" do
    let(:vacancy) do
      create(:vacancy, organisations: [organisation],
                       vacancy_analytics: build(:vacancy_analytics,
                                                referrer_counts: { "direct" => 14, "askjeeves.co.uk" => 24, "linkedin.com" => 22, "alsorans.net" => 15 }))
    end

    it "cam switch between views" do
      find_by_id("accessible").click
      within("#analytics") do
        expect(all(".govuk-summary-list__row").map(&:text)).to eq(["Askjeeves.co.uk24", "Linkedin.com22", "Alsorans.net15", "Direct14"])
      end
    end
  end

  describe "listing and application data" do
    let(:vacancy) { create(:vacancy, organisations: [organisation]) }

    it "shows the statistics" do
      within("#vacancy_statistics") do
        within(".govuk-table__row:nth-child(1)") do
          expect(page).to have_content(I18n.t("publishers.vacancies.statistics.show.views_by_jobseeker").to_s)
          expect(page).to have_content("42")
        end
        within(".govuk-table__row:nth-child(2)") do
          expect(page).to have_content(I18n.t("publishers.vacancies.statistics.show.saves_by_jobseeker").to_s)
          expect(page).to have_content("1")
        end
      end

      within("#job_applications_statistics") do
        within(".govuk-table__row:nth-child(1)") do
          expect(page).to have_content(I18n.t("publishers.vacancies.statistics.show.total_applications").to_s)
          expect(page).to have_content("4")
        end
        within(".govuk-table__row:nth-child(2)") do
          expect(page).to have_content(I18n.t("publishers.vacancies.statistics.show.unread_applications").to_s)
          expect(page).to have_content("1")
        end
        within(".govuk-table__row:nth-child(3)") do
          expect(page).to have_content(I18n.t("publishers.vacancies.statistics.show.shortlisted_applications").to_s)
          expect(page).to have_content("1")
        end
        within(".govuk-table__row:nth-child(4)") do
          expect(page).to have_content(I18n.t("publishers.vacancies.statistics.show.rejected_applications").to_s)
          expect(page).to have_content("1")
        end
        within(".govuk-table__row:nth-child(5)") do
          expect(page).to have_content(I18n.t("publishers.vacancies.statistics.show.withdrawn_applications").to_s)
          expect(page).to have_content("1")
        end
      end
    end
  end
end
