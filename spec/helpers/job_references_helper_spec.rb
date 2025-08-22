require "rails_helper"

RSpec.describe JobReferencesHelper do
  describe "#reference_request_status" do
    context "when marked complete" do
      let(:reference_request) { build_stubbed(:reference_request, marked_as_complete: true) }
      let(:job_reference) { build_stubbed(:job_reference) }

      it "shows as completed" do
        expect(reference_request_status(reference_request, job_reference)).to eq("completed")
      end
    end

    context "when not sent" do
      let(:reference_request) { build_stubbed(:reference_request) }
      let(:job_reference) { build_stubbed(:job_reference) }

      it "shows as created" do
        expect(reference_request_status(reference_request, job_reference)).to eq("created")
      end
    end

    context "when sent" do
      let(:reference_request) { build_stubbed(:reference_request, status: :requested) }

      context "when declined" do
        let(:job_reference) { build_stubbed(:job_reference, :reference_declined) }

        it "shows as declined" do
          expect(reference_request_status(reference_request, job_reference)).to eq("declined")
        end
      end

      context "when returned" do
        let(:job_reference) { build_stubbed(:job_reference, :reference_given) }

        it "shows as declined" do
          expect(reference_request_status(reference_request, job_reference)).to eq("received")
        end
      end

      context "when still in flight" do
        let(:job_reference) { build_stubbed(:job_reference) }

        it "shows as declined" do
          expect(reference_request_status(reference_request, job_reference)).to eq("pending")
        end
      end
    end
  end
end
