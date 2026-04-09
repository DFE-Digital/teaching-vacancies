require "rails_helper"

RSpec.describe "Job applications references" do
  let(:vacancy) { create(:vacancy) }
  let(:organisation) { vacancy.organisations.first }
  let(:job_application) { create(:job_application, :status_submitted, vacancy:) }
  let(:referee) { create(:referee, job_application:) }
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "DELETE #destroy" do
    it "destroys the referee and redirects to pre-interview checks" do
      delete organisation_job_job_application_reference_path(vacancy.id, job_application.id, referee.id)

      expect { referee.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(response).to redirect_to(pre_interview_checks_organisation_job_job_application_path(vacancy.id, job_application.id))
    end
  end
end
