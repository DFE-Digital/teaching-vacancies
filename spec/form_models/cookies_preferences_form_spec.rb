require "rails_helper"

RSpec.describe CookiesPreferencesForm, type: :model do
  let(:cookies_consent) { "yes" }

  let(:params) { { cookies_consent: cookies_consent } }
  let(:subject) { described_class.new(params) }

  describe "#initialize" do
    it "assigns attributes" do
      expect(subject.cookies_consent).to eq(cookies_consent)
    end
  end

  describe "#validations" do
    context "when cookies_consent is blank" do
      let(:cookies_consent) { nil }

      it "is invalid" do
        expect(subject.valid?).to be false
      end

      it "raises correct error message" do
        subject.valid?

        expect(subject.errors.messages[:cookies_consent].first).to eq(
          I18n.t("cookies_preferences_errors.cookies_consent.inclusion"),
        )
      end
    end

    context "when cookies_consent is not 'yes' or 'no'" do
      let(:cookies_consent) { "invalid_option" }

      it "is invalid" do
        expect(subject.valid?).to be false
      end

      it "raises correct error message" do
        subject.valid?

        expect(subject.errors.messages[:cookies_consent].first).to eq(
          I18n.t("cookies_preferences_errors.cookies_consent.inclusion"),
        )
      end
    end

    context "when cookies_consent is valid" do
      let(:cookies_consent) { "yes" }

      it "is valid" do
        expect(subject.valid?).to be true
      end
    end
  end
end
