require "rails_helper"

RSpec.describe Publishers::JobListing::ApplyingForTheJobForm, type: :model do
  it { is_expected.to allow_value("https://www.this-is-a-test-url.tvs").for(:application_link) }
  it { is_expected.to allow_value("").for(:application_link) }
  it { is_expected.not_to allow_value("invalid_link").for(:application_link) }

  it { is_expected.to validate_presence_of(:contact_email) }
  it { is_expected.to allow_value("thestrokes@example.com").for(:contact_email) }
  it { is_expected.not_to allow_value("invalid-email").for(:contact_email) }

  it { is_expected.to allow_value("01234 123456").for(:contact_number) }
  it { is_expected.to allow_value("").for(:application_link) }
  it { is_expected.not_to allow_value("invalid-01234").for(:contact_number) }

  context "when enable_job_applications is false" do
    subject { described_class.new(enable_job_applications: "false") }

    it { is_expected.to validate_presence_of(:how_to_apply) }
  end

  describe "enable job applications override" do
    subject { described_class.new(current_organisation: organisation) }

    context "when the current organisation given is a local authority" do
      let(:organisation) { build_stubbed(:local_authority) }

      it "overrides enable_job_applications to false" do
        subject.valid?

        expect(subject.enable_job_applications).to eq(false)
        expect(subject.errors).not_to include(:enable_job_applications)
      end
    end

    context "when the current organisation given is not a local authority" do
      let(:organisation) { build_stubbed(:trust) }

      it "does not override enable_job_applications" do
        subject.valid?

        expect(subject.enable_job_applications).to be_nil
        expect(subject.errors).to include(:enable_job_applications)
      end
    end
  end
end
