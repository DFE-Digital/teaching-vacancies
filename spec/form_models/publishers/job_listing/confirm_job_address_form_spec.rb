require "rails_helper"

RSpec.describe Publishers::JobListing::ConfirmJobAddressForm, type: :model do
  context "when all fields are blank" do
    subject { described_class.new }

    it { is_expected.to be_valid }
  end

  context "when any address field is present" do
    subject { described_class.new(job_address_line1: "10 Main Street", job_address_town: "Brighton", job_address_postcode: "BN1 1AA") }

    it { is_expected.to be_valid }

    context "when job_address_line1 is missing" do
      subject { described_class.new(job_address_town: "Brighton", job_address_postcode: "BN1 1AA") }

      it { is_expected.to validate_presence_of(:job_address_line1) }
    end

    context "when job_address_town is missing" do
      subject { described_class.new(job_address_line1: "10 Main Street", job_address_postcode: "BN1 1AA") }

      it { is_expected.to validate_presence_of(:job_address_town) }
    end

    context "when job_address_postcode is missing" do
      subject { described_class.new(job_address_line1: "10 Main Street", job_address_town: "Brighton") }

      it { is_expected.to validate_presence_of(:job_address_postcode) }
    end
  end
end
