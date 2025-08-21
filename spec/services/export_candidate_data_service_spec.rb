require "rails_helper"
require "zip"

RSpec.describe ExportCandidateDataService do
  let(:vacancy) { create(:vacancy) }
  let(:organisation) { vacancy.organisations.first }
  # referee
  let(:referee_one) { create(:referee, job_application:, name: "john e. smith") }
  let(:referee_two) { create(:referee, job_application:, name: "etha may") }
  let(:referee_no_request) { create(:referee, job_application:) }
  # requests
  let(:reference_request_one) do
    referee_one.create_reference_request!(token: SecureRandom.uuid, status: :received, email: referee_one.email)
  end
  let(:reference_request_two) do
    referee_two.create_reference_request!(token: SecureRandom.uuid, status: :received, email: referee_two.email)
  end
  let(:reference_requests) { [reference_request_one, reference_request_two] }
  # references
  let(:job_reference_one) { create(:job_reference, :reference_given, referee: referee_one) }
  let(:job_reference_two) { create(:job_reference, referee: referee_two, can_give_reference: false) }
  let(:job_references) { [job_reference_one, job_reference_two] }
  # self disclosure
  let(:self_disclosure_request) { create(:self_disclosure_request, job_application:) }
  let(:self_disclosure) { create(:self_disclosure, self_disclosure_request:) }
  # job application
  let(:job_application) do
    create(:job_application, :status_offered, vacancy:, first_name: "John", last_name: "Doe")
  end
  let(:job_applications) { [job_application] }
  # service
  let(:service) { described_class.new(job_applications) }

  before do
    referee_no_request
    reference_requests
    job_references
    self_disclosure
  end

  describe ".call" do
    it "creates new instance and calls export" do
      service_instance = instance_double(described_class)
      allow(described_class).to receive(:new).with(job_applications).and_return(service_instance)
      expect(service_instance).to receive(:export)
      described_class.call(job_applications)
    end
  end

  describe "#sanitize" do
    it "downcases and replaces spaces with underscores" do
      expect(service.sanitize("John Doe")).to eq("john_doe")
      expect(service.sanitize("JANE e. SMITH")).to eq("jane_e__smith")
      expect(service.sanitize("Multi Word Name")).to eq("multi_word_name")
    end
  end

  describe "#export" do
    let(:zip_buffer) { double }
    let(:job_references) { [job_reference_one] }

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

    it { expect(document.filename).to eq(job_application.submitted_application_form.filename) }
    it { expect(document.data).to eq(job_application.submitted_application_form.data) }
  end

  describe "#references" do
    subject(:documents) { service.references(job_application) }

    context "when request has been sent to referee" do
      it { expect(documents.count).to eq(2) }
      it { expect(documents.first.filename).to eq("references/john_e__smith.pdf") }
      it { expect(documents.first.data).to include("%PDF-") }
      it { expect(documents.last.filename).to eq("references/etha_may.pdf") }
      it { expect(documents.last.data).to include("%PDF-") }
    end

    context "when request has not been sent to referee" do
      let(:reference_requests) { [] }

      it { expect(documents.filename).to eq("no_references_found.txt") }
      it { expect(documents.data).to eq("No references have been requested through Teaching Vacancies.") }
    end
  end

  describe "#self_disclosure" do
    subject(:document) { service.self_disclosure(job_application) }

    context "when job application has self disclosure" do
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
