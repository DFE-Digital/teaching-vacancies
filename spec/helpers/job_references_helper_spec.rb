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
      let(:reference_request) { build_stubbed(:reference_request, :not_sent) }
      let(:job_reference) { build_stubbed(:job_reference) }

      it "shows as created" do
        expect(reference_request_status(reference_request, job_reference)).to eq("created")
      end
    end

    context "when received off service" do
      let(:reference_request) { build_stubbed(:reference_request, status: :received_off_service) }
      let(:job_reference) { build_stubbed(:job_reference) }

      it "shows as created" do
        expect(reference_request_status(reference_request, job_reference)).to eq("received")
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

  describe "#contact_referees_message" do
    context "when one of one" do
      let(:job_applications) { build_stubbed_list(:job_application, 1, notify_before_contact_referers: true) }

      it "returns single" do
        expect(contact_referees_message(job_applications)).to eq("single")
      end
    end

    context "when all of many" do
      let(:job_applications) { build_stubbed_list(:job_application, 2, notify_before_contact_referers: true) }

      it "returns single" do
        expect(contact_referees_message(job_applications)).to eq("all")
      end
    end

    context "when one of many" do
      let(:job_applications) do
        [
          build_stubbed(:job_application, notify_before_contact_referers: false),
          build_stubbed(:job_application, notify_before_contact_referers: true),
        ]
      end

      it "returns one" do
        expect(contact_referees_message(job_applications)).to eq("one")
      end
    end

    context "when some of many" do
      let(:job_applications) do
        [
          build_stubbed(:job_application, notify_before_contact_referers: false),
          build_stubbed(:job_application, notify_before_contact_referers: true),
          build_stubbed(:job_application, notify_before_contact_referers: true),
        ]
      end

      it "returns one" do
        expect(contact_referees_message(job_applications)).to eq("some")
      end
    end
  end
end
