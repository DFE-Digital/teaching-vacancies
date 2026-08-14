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
  it { is_expected.to allow_value("https://www.this-is-a-test-url.example.com?utm_source=teaching_vacancies").for(:application_link) }
  it { is_expected.to allow_value("https://www.this-is-a-test-url.example.com/apply?utm_source=teaching_vacancies&utm_medium=referral&utm_campaign=jobs").for(:application_link) }
  it { is_expected.to allow_value("https://www.this-is-a-test-url.example.com/apply?utm_content=a%20b#form").for(:application_link) }

  describe "normalising the application link" do
    it "strips surrounding whitespace so a pasted link is still valid" do
      form = described_class.new(application_link: "  https://www.this-is-a-test-url.example.com\n")

      expect(form).to be_valid
      expect(form.application_link).to eq("https://www.this-is-a-test-url.example.com")
    end

    it "strips surrounding whitespace without disturbing tracking parameters" do
      form = described_class.new(application_link: " https://www.this-is-a-test-url.example.com/apply?utm_source=teaching_vacancies&utm_medium=referral ")

      expect(form).to be_valid
      expect(form.application_link).to eq("https://www.this-is-a-test-url.example.com/apply?utm_source=teaching_vacancies&utm_medium=referral")
    end

    it "treats a whitespace-only link as blank" do
      form = described_class.new(application_link: "   ")

      expect(form).not_to be_valid
      expect(form.errors).to be_of_kind(:application_link, :blank)
    end

    it "leaves a nil link untouched" do
      form = described_class.new(application_link: nil)

      expect(form).not_to be_valid
      expect(form.application_link).to be_nil
    end
  end

  describe "#params_to_save" do
    let(:application_link_form) { described_class.new(application_link: "https://example.com/apply") }

    it "includes the application_link" do
      expect(application_link_form.params_to_save).to include(application_link: "https://example.com/apply")
    end
  end
end
