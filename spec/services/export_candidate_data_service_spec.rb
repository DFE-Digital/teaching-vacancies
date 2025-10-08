require "rails_helper"
require "zip"

RSpec.describe ExportCandidateDataService do
  let(:job_applications) { [job_application] }
  let(:service) { described_class.new(job_applications) }

  describe ".call" do
    let(:job_application) { build_stubbed(:job_application) }

    it "creates new instance and calls export" do
      service_instance = instance_double(described_class)
      allow(described_class).to receive(:new).with(job_applications).and_return(service_instance)
      expect(service_instance).to receive(:export)
      described_class.call(job_applications)
    end
  end

  describe "#sanitize" do
    let(:job_application) { build_stubbed(:job_application) }

    it "downcases and replaces spaces with underscores" do
      expect(service.sanitize("John Doe")).to eq("john_doe")
      expect(service.sanitize("JANE e. SMITH")).to eq("jane_e__smith")
      expect(service.sanitize("Multi Word Name")).to eq("multi_word_name")
    end
  end

  describe "#export" do
    let(:zip_buffer) { double }

    let(:job_application) do
      build_stubbed(:job_application,
                    first_name: "John", last_name: "Doe",
                    referees: [
                      build_stubbed(:referee, name: "john e. smith", reference_request: build_stubbed(:reference_request, job_reference: build_stubbed(:job_reference, :reference_given))),
                    ],
                    self_disclosure_request: build_stubbed(:self_disclosure_request, self_disclosure: build_stubbed(:self_disclosure)))
    end

    before do
      allow(zip_buffer).to receive(:rewind)
      allow(Zip::OutputStream).to receive(:write_buffer).and_yield(zip_buffer)
      allow(service).to receive_messages(pii_csv: described_class::Document["pii.csv", "csv_content"],
                                         application_form: described_class::Document["application_form.pdf", "form_data"],
                                         references: [
                                           described_class::Document["references/john_smith.pdf", "ref_data"],
                                         ],
                                         self_disclosure: described_class::Document["self_disclosure.pdf", "disclosure_data"])
    end

    it "creates zip with correct structure" do
      expect(zip_buffer).to receive(:put_next_entry).with("john_doe/pii.csv")
      expect(zip_buffer).to receive(:put_next_entry).with("john_doe/application_form.pdf")
      expect(zip_buffer).to receive(:put_next_entry).with("john_doe/references/john_smith.pdf")
      expect(zip_buffer).to receive(:put_next_entry).with("john_doe/self_disclosure.pdf")

      expect(zip_buffer).to receive(:write).with("csv_content")
      expect(zip_buffer).to receive(:write).with("form_data")
      expect(zip_buffer).to receive(:write).with("ref_data")
      expect(zip_buffer).to receive(:write).with("disclosure_data")

      service.export
    end
  end

  describe "#pii_csv" do
    subject(:document) { service.pii_csv(job_application) }

    let(:job_application) { build_stubbed(:job_application) }
    let(:expected_headers) do
      %w[first_name last_name street_address city postcode phone_number email_address national_insurance_number teacher_reference_number]
    end
    let(:headers_line) { document.data.split("\n").first }
    let(:data_line) { document.data.split("\n").last }

    it { expect(document.filename).to eq("pii.csv") }
    it { expect(headers_line).to eq(expected_headers.join(",")) }
    it { expect(data_line).to eq(job_application.attributes.slice(*expected_headers).values.join(",")) }
  end

  describe "#application_form" do
    subject(:document) { service.application_form(job_application) }

    let(:job_application) { build_stubbed(:job_application) }

    it { expect(document.filename).to eq(job_application.submitted_application_form.filename) }
    it { expect(document.data).to eq(job_application.submitted_application_form.data) }
  end

  describe "#references" do
    subject(:documents) { service.references(job_application) }

    context "when request has been sent to referee" do
      let(:job_application) do
        build_stubbed(:job_application,
                      referees: [
                        build_stubbed(:referee, name: "john e. smith", reference_request: build_stubbed(:reference_request, job_reference: build_stubbed(:job_reference, :reference_given))),
                        build_stubbed(:referee, name: "etha may", reference_request: build_stubbed(:reference_request, job_reference: build_stubbed(:job_reference, :reference_declined))),
                        build_stubbed(:referee, name: "request_not_sent", reference_request: build_stubbed(:reference_request, :not_sent)),
                        build_stubbed(:referee, name: "reference not returned yet", reference_request: build_stubbed(:reference_request, job_reference: build_stubbed(:job_reference))),
                        build_stubbed(:referee, name: "referee_no_request"),
                      ])
      end

      it { expect(documents.count).to eq(2) }
      it { expect(documents.first.filename).to eq("references/john_e__smith.pdf") }
      it { expect(documents.first.data).to include("%PDF-") }
      it { expect(documents.last.filename).to eq("references/etha_may.pdf") }
      it { expect(documents.last.data).to include("%PDF-") }
    end

    context "when request has not been sent to referee" do
      let(:job_application) do
        build_stubbed(:job_application,
                      referees: [
                        build_stubbed(:referee, name: "john e. smith", reference_request: build_stubbed(:reference_request, :not_sent)),
                        build_stubbed(:referee, name: "referee_no_request"),
                      ])
      end

      it { expect(documents.filename).to eq("no_references_found.txt") }
      it { expect(documents.data).to eq("No references have been requested through Teaching Vacancies.") }
    end
  end

  describe "#self_disclosure" do
    let(:document) { service.self_disclosure(job_application) }
    let(:job_application) do
      create(:job_application,
             self_disclosure_request: build(:self_disclosure_request, self_disclosure: self_disclosure))
    end

    # self-disclosure requests have an attached self-disclosure iff they are sent.
    context "when job application has self disclosure" do
      let(:self_disclosure) { build(:self_disclosure) }

      it { expect(document.filename).to eq("self_disclosure.pdf") }
      it { expect(document.data).to include("%PDF-") }
    end

    context "when job application has no self disclosure" do
      let(:self_disclosure) { nil }

      it { expect(document.filename).to eq("no_declarations_found.txt") }
      it { expect(document.data).to eq("No self-disclosure form has been submitted through Teaching Vacancies.") }
    end
  end
end
