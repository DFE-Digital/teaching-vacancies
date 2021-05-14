require "rails_helper"

RSpec.describe CopyVacancy do
  describe "#call" do
    let(:document_copy) { double("document_copy") }

    before do
      allow(DocumentCopy).to receive(:new).and_return(document_copy)
      allow(document_copy).to receive(:copy).and_return(document_copy)
      allow(document_copy).to receive_message_chain(:copied, :web_content_link).and_return("test_url")
      allow(document_copy).to receive_message_chain(:copied, :id).and_return("test_id")
      allow(document_copy).to receive(:google_error).and_return(false)
    end

    it "creates a new vacancy as draft" do
      vacancy = create(:vacancy, job_title: "Maths teacher")

      result = described_class.new(vacancy).call

      expect(result).to be_kind_of(Vacancy)
      expect(Vacancy.count).to eq(2)
      expect(Vacancy.find(result.id).status).to eq("draft")
    end

    it "does not change the original vacancy" do
      # Needed to compare a FactoryBot object fields for updated_at and created_at
      # and against the record it creates in Postgres.
      travel_to(Time.zone.local(2008, 9, 1, 12, 0, 0)) do
        vacancy = create(:vacancy, job_title: "Maths teacher")

        described_class.new(vacancy).call

        expect(Vacancy.find(vacancy.id).attributes == vacancy.attributes)
          .to eq(true)
      end
    end

    describe "#documents" do
      it "copies documents when copying a vacancy" do
        document = create(:document,
                          name: "Test.png",
                          size: 1000,
                          content_type: "image/png",
                          download_url: "test/test.png",
                          google_drive_id: "testid")
        vacancy = create(:vacancy, documents: [document])

        result = described_class.new(vacancy).call

        expect(result.documents.first.name).to eq(vacancy.documents.first.name)
      end
    end

    context "not all fields are copied" do
      let(:vacancy) do
        create(:vacancy,
               job_title: "Maths teacher",
               slug: "maths-teacher",
               total_pageviews: 4,
               total_get_more_info_clicks: 6)
      end
      let(:result) { described_class.new(vacancy).call }

      it "does not copy the slug of a vacancy" do
        expect(Vacancy.find(result.id).slug).to_not eq("maths-teacher")
      end

      it "does not copy the total page views of a vacancy" do
        expect(Vacancy.find(result.id).total_pageviews).to eq(0)
      end

      it "does not copy the get more info clicks of a vacancy" do
        expect(Vacancy.find(result.id).total_get_more_info_clicks).to eq(0)
      end
    end
  end
end
