require "rails_helper"

RSpec.describe Publishers::JobListing::ApplyingForTheJobDetailsForm, type: :model do
  subject { described_class.new(current_organisation: organisation, vacancy: vacancy) }

  let(:organisation) { build_stubbed(:trust) }
  let(:vacancy) { build_stubbed(:vacancy, enable_job_applications: enable_job_applications) }
  let(:enable_job_applications) { true }

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
    subject { described_class.new(current_organisation: organisation, vacancy: vacancy) }

    let(:enable_job_applications) { false }

    it { is_expected.to validate_presence_of(:how_to_apply) }
  end
end
