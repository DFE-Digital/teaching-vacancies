require "rails_helper"
require "dfe/analytics/rspec/matchers"

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

      it "triggers a `vacancy_document_downloaded` event", :dfe_analytics do
        get job_document_path(vacancy, document.id)

        expect(:vacancy_document_downloaded).to have_been_enqueued_as_analytics_event( # rubocop:disable RSpec/ExpectActual
          with_data: { vacancy_id: vacancy.id,
                       document_type: "supporting_document",
                       document_id: document.id,
                       filename: document.filename },
        )
      end
    end
  end

  context "with application form" do
    let(:vacancy) { create(:vacancy, :with_uploaded_application_form, organisations: [build(:school)]) }
    let(:document) { vacancy.application_form }

    describe "GET #show" do
      context "when the blob is not clean" do
        before { document.blob.malware_scan_pending! }

        it "redirects to the job path with an alert" do
          get job_document_path(vacancy, document.id)

          expect(response).to redirect_to(job_path(vacancy))
          expect(flash[:alert]).to eq(I18n.t("active_storage.blobs.file_unavailable"))
        end
      end

      it "redirects to the document link, with a 301 status (in order to save it from being crawled)" do
        get job_document_path(vacancy, document.id)

        expect(response).to redirect_to(document)
        expect(response.status).to eq(301)
      end

      it "triggers a `vacancy_document_downloaded` event", :dfe_analytics do
        get job_document_path(vacancy, document.id)

        expect(:vacancy_document_downloaded).to have_been_enqueued_as_analytics_event( # rubocop:disable RSpec/ExpectActual
          with_data: { vacancy_id: vacancy.id,
                       document_type: "application_form",
                       document_id: document.id,
                       filename: document.filename },
        )
      end
    end
  end
end
