require "rails_helper"

RSpec.describe "Publishers can reject a job application" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_job_job_application_path(vacancy.id, job_application.id)
  end

  it "rejects the job application after confirmation" do
    click_on I18n.t("buttons.reject")

    expect(current_path).to eq(organisation_job_job_application_reject_path(vacancy.id, job_application.id))

    fill_in "publishers_job_application_update_status_form[rejection_reasons]", with: "Some rejection reasons"
    click_on I18n.t("buttons.confirm_rejection")

    expect(current_path).to eq(organisation_job_job_applications_path(vacancy.id))
    expect(page).to have_content(I18n.t("publishers.vacancies.job_applications.update_status.unsuccessful",
                                        name: job_application.name))
    expect(job_application.reload.status).to eq("unsuccessful")
  end
end
