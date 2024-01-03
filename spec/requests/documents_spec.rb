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

      it "triggers a `vacancy_document_downloaded` event" do
        get job_document_path(vacancy, document.id)

        expect(:vacancy_document_downloaded).to have_been_enqueued_as_analytics_events
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
        get job_document_path(vacancy, document.id)

        expect(:vacancy_document_downloaded).to have_been_enqueued_as_analytics_events
      end
    end
  end
end
