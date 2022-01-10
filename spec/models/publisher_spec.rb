require "rails_helper"

RSpec.describe Publisher do
  it { is_expected.to have_many(:organisations) }
  it { is_expected.to have_many(:organisation_publishers) }
  it { is_expected.to have_many(:publisher_preferences) }
  it { is_expected.to have_many(:emergency_login_keys) }
  it { is_expected.to have_many(:vacancies) }
  it { is_expected.to have_many(:notifications) }

  describe "#vacancies_with_job_applications_submitted_yesterday" do
    let!(:publisher) { create(:publisher) }
    let!(:vacancy1) { create(:vacancy, publisher:) }
    let!(:vacancy2) { create(:vacancy, publisher:) }
    let!(:job_application1) { create(:job_application, :status_submitted, vacancy: vacancy1, submitted_at: 1.day.ago) }
    let!(:job_application2) { create(:job_application, :status_submitted, vacancy: vacancy2, submitted_at: 2.days.ago) }

    it "returns vacancies with job applications submitted yesterday" do
      expect(publisher.vacancies_with_job_applications_submitted_yesterday).to eq [vacancy1]
    end
  end
end
