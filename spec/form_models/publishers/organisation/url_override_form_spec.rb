require "rails_helper"

RSpec.describe Publishers::Organisation::UrlOverrideForm, type: :model do
  it { is_expected.to allow_value("https://www.this-is-a-test-url.example.com").for(:url_override) }
  it { is_expected.not_to allow_value("www.this-is-a-test-url.example.com").for(:url_override) }
  it { is_expected.to allow_value("").for(:url_override) }
  it { is_expected.not_to allow_value("invalid_url_override").for(:url_override) }
  it { is_expected.to allow_value("https://www.this-is-a-test-url.example.com?utm_source=teaching_vacancies").for(:url_override) }
  it { is_expected.to allow_value("https://www.this-is-a-test-url.example.com/jobs?utm_source=teaching_vacancies&utm_medium=referral&utm_campaign=jobs").for(:url_override) }
  it { is_expected.to allow_value("https://www.this-is-a-test-url.example.com/jobs?utm_content=a%20b#list").for(:url_override) }

  describe "normalising the url override" do
    it "strips surrounding whitespace so a pasted link is still valid" do
      form = described_class.new(url_override: "  https://www.this-is-a-test-url.example.com\n")

      expect(form).to be_valid
      expect(form.url_override).to eq("https://www.this-is-a-test-url.example.com")
    end

    it "strips surrounding whitespace without disturbing tracking parameters" do
      form = described_class.new(url_override: " https://www.this-is-a-test-url.example.com/jobs?utm_source=teaching_vacancies&utm_medium=referral ")

      expect(form).to be_valid
      expect(form.url_override).to eq("https://www.this-is-a-test-url.example.com/jobs?utm_source=teaching_vacancies&utm_medium=referral")
    end

    it "treats a whitespace-only url as blank" do
      form = described_class.new(url_override: "   ")

      expect(form).to be_valid
      expect(form.url_override).to eq("")
    end

    it "leaves a nil url untouched" do
      form = described_class.new(url_override: nil)

      expect(form).to be_valid
      expect(form.url_override).to be_nil
    end
  end
end
