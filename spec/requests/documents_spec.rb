require "rails_helper"

RSpec.describe "Documents" do
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:supporting_document) do
    vacancy.supporting_documents.attach(fixture_file_upload("blank_job_spec.pdf"))
    vacancy.supporting_documents.first
  end

  describe "GET #show" do
    it "redirects to ActiveStorage" do
      get job_document_path(vacancy, supporting_document)

      expect(response).to redirect_to(supporting_document)
    end

    it "triggers a `vacancy_document_downloaded` event" do
      expect { get job_document_path(vacancy, supporting_document) }
        .to have_triggered_event(:vacancy_document_downloaded)
        .and_data(
          vacancy_id: vacancy.id,
          document_id: supporting_document.id,
          filename: supporting_document.filename,
        )
    end
  end
end
