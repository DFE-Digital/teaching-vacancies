require "rails_helper"

RSpec.describe "Documents" do
  context "with supporting documents" do
    let(:vacancy) { create(:vacancy, :with_supporting_documents, organisations: [build(:school)]) }
    let(:document) { vacancy.supporting_documents.first }

    describe "GET #show" do
      it "redirects to the document link, with a 301 status (in order to save it from being crawled)" do
        get job_document_path(vacancy, document.id)

        expect(response).to redirect_to(document)
        expect(response.status).to eq(301)
      end

      it "triggers a `vacancy_document_downloaded` event" do
        expect { get job_document_path(vacancy, document.id) }
          .to have_triggered_event(:vacancy_document_downloaded)
          .and_data(
            vacancy_id: anonymised_form_of(vacancy.id),
            document_type: "supporting_document",
            document_id: anonymised_form_of(document.id),
            filename: document.filename,
          )
      end
    end
  end

  context "with application form" do
    let(:vacancy) { create(:vacancy, :with_application_form, organisations: [build(:school)]) }
    let(:document) { vacancy.application_form }

    describe "GET #show" do
      it "redirects to the document link, with a 301 status (in order to save it from being crawled)" do
        get job_document_path(vacancy, document.id)

        expect(response).to redirect_to(document)
        expect(response.status).to eq(301)
      end

      it "triggers a `vacancy_document_downloaded` event" do
        expect { get job_document_path(vacancy, document.id) }
          .to have_triggered_event(:vacancy_document_downloaded)
          .and_data(
            vacancy_id: anonymised_form_of(vacancy.id),
            document_type: "application_form",
            document_id: anonymised_form_of(document.id),
            filename: document.filename,
          )
      end
    end
  end
end
