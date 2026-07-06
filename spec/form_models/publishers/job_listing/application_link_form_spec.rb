require "rails_helper"

RSpec.describe Publishers::JobListing::ApplicationLinkForm, type: :model do
  subject { described_class.new }

  let(:organisation) { build_stubbed(:trust) }
  let(:vacancy) { build_stubbed(:vacancy, enable_job_applications: enable_job_applications) }
  let(:enable_job_applications) { true }

  it { is_expected.to allow_value("https://www.this-is-a-test-url.example.com").for(:application_link) }
  it { is_expected.not_to allow_value("www.this-is-a-test-url.example.com").for(:application_link) }
  it { is_expected.not_to allow_value("").for(:application_link) }
  it { is_expected.not_to allow_value("email@school.com").for(:application_link) }
  it { is_expected.not_to allow_value("A full application pack can be found at www.website.co.uk").for(:application_link) }

  describe "#params_to_save" do
    let(:application_link_form) { described_class.new(application_link: "https://example.com/apply") }

    it "includes the application_link" do
      expect(application_link_form.params_to_save).to include(application_link: "https://example.com/apply")
    end

    it "sets enable_job_applications to false" do
      expect(application_link_form.params_to_save).to include(enable_job_applications: false)
    end

    it "sets receive_applications to website" do
      expect(application_link_form.params_to_save).to include(receive_applications: :website)
    end
  end
end
