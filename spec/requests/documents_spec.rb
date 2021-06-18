require "rails_helper"

RSpec.describe "Documents" do
  let(:vacancy) { create(:vacancy, :with_supporting_documents, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:document) { vacancy.supporting_documents.first }

  describe "GET #show" do
    it "redirects to the document link" do
      get job_document_path(vacancy, document)

      expect(response).to redirect_to(document)
    end

    it "triggers a `vacancy_document_downloaded` event" do
      expect { get job_document_path(vacancy, document) }
        .to have_triggered_event(:vacancy_document_downloaded)
        .and_data(vacancy_id: anonymised_form_of(vacancy.id), document_id: anonymised_form_of(document.id), filename: document.filename)
    end
  end
end
