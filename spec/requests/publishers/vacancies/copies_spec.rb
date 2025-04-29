require 'rails_helper'

RSpec.describe "copy", type: :request do
  let(:publisher) { create(:publisher) }
  let(:organisation) { build(:school) }

  before do
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "POST /copy" do
    let(:vacancy) { create(:vacancy, :with_application_form, :with_supporting_documents, organisations: [organisation]) }

    it "doesn't crash" do
      post organisation_job_copy_path(vacancy.id)
      expect(response).to have_http_status(302)
    end
  end
end
