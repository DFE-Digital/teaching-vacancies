require "rails_helper"

RSpec.describe "Publishers can view a job application" do
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
  let(:oid) { SecureRandom.uuid }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    stub_publishers_auth(urn: organisation.urn, oid: oid)
    visit organisation_job_job_application_path(vacancy.id, job_application.id)
  end

  it "shows the job application page" do
    # TODO: Complete this spec
    expect(page).to have_content("TV12345 - #{job_application.application_data['first_name']} #{job_application.application_data['last_name']}")
  end
end
