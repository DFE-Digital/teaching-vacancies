require "rails_helper"

RSpec.describe "Publishers::Vacancies::JobApplicationsController#download_application_form" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:job_application) { create(:uploaded_job_application, vacancy: vacancy) }

  before do
    sign_in(publisher, scope: :publisher)
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
  end

  after { sign_out publisher }

  context "when the application form is attached" do
    before do
      job_application.application_form.attach(
        io: Rails.root.join("spec/fixtures/files/blank_job_spec.pdf").open,
        filename: "sample.pdf",
        content_type: "application/pdf",
      )
    end

    it "sends the application form file" do
      get organisation_job_job_application_download_path(vacancy.id, job_application.id)

      expect(response).to be_successful
      expect(response.body).to include("%PDF")
    end
  end
end
