require "rails_helper"

RSpec.describe "copy" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { build(:school) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "POST /copy" do
    let(:vacancy) { create(:vacancy, :with_uploaded_application_form, :with_supporting_documents, organisations: [organisation]) }

    # This sort of doesn't happen any more - we're not creating a vacancy...
    it "sends analytics events", :dfe_analytics do
      pending("copying changes")

      post organisation_job_copy_path(vacancy.id), params: { publishers_vacancies_copy_vacancy_form: { name: "name" } }

      expect(:supporting_document_created).to have_been_enqueued_as_analytics_event
    end
  end
end
