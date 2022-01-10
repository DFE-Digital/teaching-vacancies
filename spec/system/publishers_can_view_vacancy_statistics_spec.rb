require "rails_helper"

RSpec.describe "Publishers can view a job application" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }

  before do
    create(:saved_job, vacancy:)
    create(:job_application, :status_submitted, vacancy:)
    create(:job_application, :status_shortlisted, vacancy:)
    create(:job_application, :status_unsuccessful, vacancy:)
    create(:job_application, :status_withdrawn, vacancy:)

    login_publisher(publisher:, organisation:)
    vacancy_stats = instance_double("Publishers::VacancyStats", number_of_unique_views: 42)
    allow(Publishers::VacancyStats).to receive(:new).with(vacancy).and_return(vacancy_stats)
    visit organisation_job_statistics_path(vacancy.id)
  end

  it "shows the statistics" do
    within("#vacancy_statistics") do
      expect(page).to have_content("#{I18n.t('publishers.vacancies.statistics.show.views_by_jobseeker')}42")
      expect(page).to have_content("#{I18n.t('publishers.vacancies.statistics.show.saves_by_jobseeker')}1")
    end

    within("#job_applications_statistics") do
      expect(page).to have_content("#{I18n.t('publishers.vacancies.statistics.show.total_applications')}4")
      expect(page).to have_content("#{I18n.t('publishers.vacancies.statistics.show.unread_applications')}1")
      expect(page).to have_content("#{I18n.t('publishers.vacancies.statistics.show.shortlisted_applications')}1")
      expect(page).to have_content("#{I18n.t('publishers.vacancies.statistics.show.rejected_applications')}1")
      expect(page).to have_content("#{I18n.t('publishers.vacancies.statistics.show.withdrawn_applications')}1")
    end
  end
end
