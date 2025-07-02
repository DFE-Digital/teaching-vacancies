require "rails_helper"
require "zip"

RSpec.describe JobApplicationZipBuilder do
  describe "#generate" do
    context "when vacancy uses uploaded application forms" do
      it "includes attached uploaded files in the zip" do
        vacancy = create(:vacancy, :with_uploaded_application_form)
        job_application = create(:uploaded_job_application, vacancy:)
        file = fixture_file_upload("spec/fixtures/files/blank_job_spec.pdf", "application/pdf")
        job_application.application_form.attach(file)

        zip_data = described_class.new(vacancy:, job_applications: [job_application]).generate.string

        entries = []
        Zip::InputStream.open(StringIO.new(zip_data)) do |zio|
          while (entry = zio.get_next_entry)
            entries << entry.name
            content = zio.read
            expect(content).to include("%PDF")
          end
        end

        expect(entries).to include("#{job_application.first_name}_#{job_application.last_name}.pdf")
      end

      it "skips job applications without uploaded form" do
        vacancy = create(:vacancy, :with_uploaded_application_form)
        vacancy.application_form.purge
        job_application = create(:uploaded_job_application, vacancy:)

        zip_data = described_class.new(vacancy:, job_applications: [job_application]).generate.string

        Zip::InputStream.open(StringIO.new(zip_data)) do |zio|
          expect(zio.get_next_entry).to be_nil
        end
      end
    end

    context "when vacancy uses native application form (PDF generation)" do
      let(:vacancy) { create(:vacancy, receive_applications: :email) } # or :website

      it "generates a PDF per job application in the zip" do
        job_application = create(:job_application, vacancy:, first_name: "Jane", last_name: "Doe")

        zip_data = described_class.new(vacancy:, job_applications: [job_application]).generate.string

        entries = []
        Zip::InputStream.open(StringIO.new(zip_data)) do |zio|
          while (entry = zio.get_next_entry)
            entries << entry.name
            content = zio.read
            expect(content).to start_with("%PDF")
          end
        end

        expect(entries).to include("Jane_Doe.pdf")
      end
    end
  end
end
