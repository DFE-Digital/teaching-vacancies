# frozen_string_literal: true

require "rails_helper"

module Jobseekers
  module JobApplication
    RSpec.describe CatholicForm, type: :model do
      describe "baptism date validation" do
        let(:form) do
          described_class.new({ "following_religion" => "true",
                                "faith" => "RC",
                                "baptism_address" => "1 The Park",
                                "religious_reference_type" => "baptism_date",
                                "catholic_section_completed" => "true",
                                "baptism_date(3i)" => day,
                                "baptism_date(2i)" => month,
                                "baptism_date(1i)" => year })
        end

        context "with a valid date" do
          let(:day) { "20" }
          let(:month) { "12" }
          let(:year) { "1990" }

          it "is valid" do
            expect(form).to be_valid
            expect(form.errors.messages).to be_empty
          end
        end

        context "with an empty date" do
          let(:day) { "" }
          let(:month) { "" }
          let(:year) { "" }

          it "is not valid" do
            expect(form).not_to be_valid
            expect(form.errors.messages).to eq(baptism_date: ["Enter the baptism date"])
          end
        end

        context "with an invalid day" do
          let(:day) { "32" }
          let(:month) { "1" }
          let(:year) { "2024" }

          it "is not valid" do
            expect(form).not_to be_valid
            expect(form.errors.messages).to eq(baptism_date: ["Enter a valid baptism date"])
          end
        end

        context "with an invalid month" do
          let(:day) { "1" }
          let(:month) { "13" }
          let(:year) { "2024" }

          it "is not valid" do
            expect(form).not_to be_valid
            expect(form.errors.messages).to eq(baptism_date: ["Enter a valid baptism date"])
          end
        end

        context "with a future date" do
          let(:year) { (Date.current.year + 1).to_s }
          let(:month) { "1" }
          let(:day) { "1" }

          it "is not valid" do
            expect(form).not_to be_valid
            expect(form.errors.messages).to eq(baptism_date: ["Baptism date must be in the past"])
          end
        end
      end

      describe "baptism_certificate_scan_safe" do
        let(:blob) { instance_double(ActiveStorage::Blob, filename: "cert.pdf") }
        let(:attachment) { double(blob: blob) }
        let(:form) do
          described_class.new({
            "following_religion" => "true",
            "faith" => "RC",
            "religious_reference_type" => "baptism_certificate",
            "catholic_section_completed" => "true",
            "baptism_certificate" => attachment,
          })
        end

        context "when the blob is malicious" do
          before do
            allow(blob).to receive(:malware_scan_malicious?).and_return(true)
            allow(blob).to receive(:malware_scan_scan_error?).and_return(false)
          end

          it "adds an unsafe_file error" do
            form.valid?
            expect(form.errors.of_kind?(:baptism_certificate, :unsafe_file)).to be true
          end
        end

        context "when the blob has a scan error" do
          before do
            allow(blob).to receive(:malware_scan_malicious?).and_return(false)
            allow(blob).to receive(:malware_scan_scan_error?).and_return(true)
          end

          it "adds an unsafe_file error" do
            form.valid?
            expect(form.errors.of_kind?(:baptism_certificate, :unsafe_file)).to be true
          end
        end

        context "when the blob is clean" do
          before do
            allow(blob).to receive(:malware_scan_malicious?).and_return(false)
            allow(blob).to receive(:malware_scan_scan_error?).and_return(false)
          end

          it "does not add an unsafe_file error" do
            form.valid?
            expect(form.errors.of_kind?(:baptism_certificate, :unsafe_file)).to be false
          end
        end
      end
    end
  end
end
