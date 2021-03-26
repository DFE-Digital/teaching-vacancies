require "rails_helper"

RSpec.describe "Documents" do
  include ActionDispatch::TestProcess::FixtureFile

  let(:publisher) { create(:publisher) }
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: organisation }]) }

  before do
    allow_any_instance_of(Publishers::AuthenticationConcerns).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  describe "POST #create" do
    before do
      post organisation_job_documents_path(vacancy.id), params: {
        publishers_job_listing_documents_form: { documents: [file] },
      }
    end

    context "with a valid file" do
      let(:file) { fixture_file_upload("blank_job_spec.pdf") }

      it "is accepted" do
        expect(response.body).not_to include(I18n.t("jobs.file_type_error_message"))
      end
    end

    context "with an invalid file" do
      let(:file) { fixture_file_upload("i_am_not_an_image.png") }

      it "is rejected even if the file extension suggests it is valid" do
        expect(response.body).to include(I18n.t("jobs.file_type_error_message", filename: "i_am_not_an_image.png"))
      end
    end
  end
end
