require "rails_helper"

RSpec.describe Publishers::JobListing::ApplyingForTheJobForm, type: :model do
  subject { described_class.new(current_organisation: organisation, vacancy: vacancy) }

  let(:organisation) { build_stubbed(:trust) }
  let(:vacancy) { build_stubbed(:vacancy) }

  it { is_expected.to allow_value("https://www.this-is-a-test-url.example.com").for(:application_link) }
  it { is_expected.to allow_value("www.this-is-a-test-url.example.com").for(:application_link) }
  it { is_expected.to allow_value("").for(:application_link) }
  it { is_expected.not_to allow_value("email@school.com").for(:application_link) }
  it { is_expected.not_to allow_value("A full application pack can be found at www.website.co.uk").for(:application_link) }

  it { is_expected.to validate_presence_of(:contact_email) }
  it { is_expected.to allow_value("thestrokes@example.com").for(:contact_email) }
  it { is_expected.not_to allow_value("invalid-email").for(:contact_email) }

  it { is_expected.to allow_value("01234 123456").for(:contact_number) }
  it { is_expected.to allow_value("").for(:application_link) }
  it { is_expected.not_to allow_value("invalid-01234").for(:contact_number) }

  context "when enable_job_applications is false" do
    subject { described_class.new(current_organisation: organisation, enable_job_applications: "false", vacancy: vacancy) }

    it { is_expected.to validate_presence_of(:how_to_apply) }
  end

  describe "enable job applications override" do
    context "when the current organisation given is a local authority" do
      let(:organisation) { build_stubbed(:local_authority) }

      it "overrides enable_job_applications and sets it to false" do
        subject.valid?

        expect(subject.enable_job_applications).to eq(false)
        expect(subject.errors).to_not include(:enable_job_applications)
      end
    end

    context "when the current organisation given is not a local authority" do
      context "when the vacancy is in draft" do
        let(:vacancy) { build_stubbed(:vacancy, :draft, job_roles: %w[teacher]) }

        it "does not override enable_job_applications" do
          subject.enable_job_applications = true

          expect { subject.valid? }.to_not(change { subject.enable_job_applications })
        end

        it "is not valid" do
          subject.valid?

          expect(subject).to_not be_valid
          expect(subject.errors).to include(:enable_job_applications)
        end
      end

      context "when the vacancy has been listed and enable_job_applications is nil" do
        subject do
          described_class.new(current_organisation: organisation,
                              vacancy: vacancy,
                              enable_job_applications: nil,
                              how_to_apply: "Test",
                              contact_email: "test@example.com")
        end

        let(:vacancy) { build_stubbed(:vacancy, :past_publish, job_roles: %w[teacher]) }

        it "overrides enable_job_applications" do
          expect { subject.valid? }.to change { subject.enable_job_applications }.from(nil).to(false)
        end

        it "is valid" do
          subject.valid?

          expect(subject).to be_valid
          expect(subject.errors).to_not include(:enable_job_applications)
        end
      end
    end
  end
end
