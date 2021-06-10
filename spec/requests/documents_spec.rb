require "rails_helper"

RSpec.describe "Documents" do
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:document) { vacancy.documents.first }

  describe "GET #show" do
    it "redirects to the document link" do
      get document_path(document)

      expect(response).to redirect_to(document.download_url)
    end

    it "triggers a `vacancy_document_downloaded` event" do
      expect { get document_path(document) }
        .to have_triggered_event(:vacancy_document_downloaded)
        .and_data(vacancy_id: anonymised_form_of(vacancy.id), document_id: anonymised_form_of(document.id), filename: document.name)
    end
  end
end
