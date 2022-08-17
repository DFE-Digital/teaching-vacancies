require "rails_helper"

RSpec.describe Publishers::JobListing::ApplicationLinkForm, type: :model do
  subject { described_class.new(current_organisation: organisation, vacancy: vacancy) }

  let(:organisation) { build_stubbed(:trust) }
  let(:vacancy) { build_stubbed(:vacancy, enable_job_applications: enable_job_applications) }
  let(:enable_job_applications) { true }

  it { is_expected.to allow_value("https://www.this-is-a-test-url.example.com").for(:application_link) }
  it { is_expected.to allow_value("www.this-is-a-test-url.example.com").for(:application_link) }
  it { is_expected.not_to allow_value("").for(:application_link) }
  it { is_expected.not_to allow_value("email@school.com").for(:application_link) }
  it { is_expected.not_to allow_value("A full application pack can be found at www.website.co.uk").for(:application_link) }
end
