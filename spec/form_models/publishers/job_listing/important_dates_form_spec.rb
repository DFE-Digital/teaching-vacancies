require "rails_helper"

RSpec.describe Publishers::JobListing::ImportantDatesForm, type: :model do
  subject { described_class.new(params) }

  context "validations" do
    let(:params) { {} }

    it { is_expected.to validate_presence_of(:publish_on) }
    it { is_expected.to validate_presence_of(:expires_on) }
    it { is_expected.to validate_presence_of(:expires_at) }

    it { is_expected.to allow_value(Time.zone.tomorrow).for(:publish_on) }
    it { is_expected.not_to allow_value(Time.zone.yesterday).for(:publish_on).with_message(I18n.t("important_dates_errors.publish_on.before_today")) }

    it { is_expected.to allow_value(Time.zone.tomorrow).for(:expires_on) }
    it { is_expected.not_to allow_value(Time.zone.yesterday).for(:expires_on).with_message(I18n.t("important_dates_errors.expires_on.before_today")) }

    it { is_expected.to allow_value(Time.zone.tomorrow).for(:starts_on) }
    it { is_expected.not_to allow_value(Time.zone.yesterday).for(:starts_on).with_message(I18n.t("important_dates_errors.starts_on.before_today")) }

    describe "#expires_on" do
      context "when the date is before publish_on" do
        let(:params) { { expires_on: Date.current, publish_on: Time.zone.tomorrow } }

        it "sets an error on expires_on" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:expires_on]).to include(I18n.t("important_dates_errors.expires_on.before_publish_on"))
        end
      end
    end

    describe "#starts_on" do
      context "when the date is before publish_on" do
        let(:params) { { starts_on: Date.current, publish_on: Time.zone.tomorrow } }

        it "must be after publish_on" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:starts_on]).to include(I18n.t("important_dates_errors.starts_on.before_publish_on"))
        end
      end

      context "when the date is before expires_on" do
        let(:params) { { starts_on: Date.current, expires_on: Time.zone.tomorrow } }

        it "must be after expires_on" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:starts_on]).to include(I18n.t("important_dates_errors.starts_on.before_expires_on"))
        end
      end

      context "when starts_asap is present" do
        let(:params) { { starts_on: Date.current, starts_asap: true } }

        it "must be blank" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:starts_on]).to include(I18n.t("important_dates_errors.starts_on.multiple_start_dates"))
        end
      end
    end

    describe "#expires_at" do
      let(:params) { { expires_at_hh: "11", expires_at_mm: "11", expires_at_meridiem: "am" } }

      context "when expires_at is blank" do
        let(:params) { { expires_at_hh: "", expires_at_mm: "", expires_at_meridiem: "" } }

        it "requests an entry in the field" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:expires_at]).to include(I18n.t("important_dates_errors.expires_at.blank"))
        end
      end

      validate_expires_at_hours = [
        { value: nil, errors: I18n.t("important_dates_errors.expires_at.blank") },
        { value: "not a number", errors: I18n.t("important_dates_errors.expires_at.wrong_format") },
        { value: "14", errors: I18n.t("important_dates_errors.expires_at.wrong_format") },
        { value: "0", errors: I18n.t("important_dates_errors.expires_at.wrong_format") },
      ]

      validate_expires_at_hours.each do |h|
        it "displays '#{h[:errors][0]}' error when hours field is #{h[:value]}" do
          subject.expires_at_hh = h[:value]
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:expires_at]).to include(h[:errors])
        end
      end

      validate_expires_at_minutes = [
        { value: nil, errors: I18n.t("important_dates_errors.expires_at.blank") },
        { value: "not a number", errors: I18n.t("important_dates_errors.expires_at.wrong_format") },
        { value: "-6", errors: I18n.t("important_dates_errors.expires_at.wrong_format") },
        { value: "66", errors: I18n.t("important_dates_errors.expires_at.wrong_format") },
      ]

      validate_expires_at_minutes.each do |m|
        it "displays '#{m[:errors][0]}' error when minutes field is #{m[:value]}" do
          subject.expires_at_mm = m[:value]
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:expires_at]).to include(m[:errors])
        end
      end

      context "when meridiem field is blank" do
        let(:params) { { expires_at_meridiem: "" } }

        it "requests an entry in the field" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:expires_at]).to include(I18n.t("important_dates_errors.expires_at.must_be_am_pm"))
        end
      end

      context "when minutes and meridiem are invalid" do
        let(:params) { { expires_at_mm: "66", expires_at_meridiem: "" } }

        it "displays wrong format error" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:expires_at]).to include(I18n.t("important_dates_errors.expires_at.wrong_format"))
        end
      end

      context "when all fields are correct" do
        it "does not display an error" do
          subject.valid?
          expect(subject.errors.messages[:expires_at]).to be_empty
        end
      end
    end
  end

  context "when expiry time components are given" do
    context "when fields are incomplete" do
      let(:params) { { expires_at_hh: "9" } }

      it "cannot save expiry time" do
        expect(subject.params_to_save).not_to include(expires_at_hh: "9")
      end
    end

    context "when fields are complete" do
      let(:params) { { expires_on: 1.week.from_now, expires_at_hh: "9", expires_at_mm: "15", expires_at_meridiem: "am" } }

      it "can save expiry time" do
        expect(subject.params_to_save.count).to eq(2)
        expect(subject.params_to_save[:expires_at].hour).to eq(9)
        expect(subject.params_to_save[:expires_at].min).to eq(15)
      end
    end
  end

  context "when all attributes are valid" do
    let(:params) do
      {
        state: "create", expires_on: 1.week.from_now, publish_on: Date.current,
        starts_on: 1.month.from_now, expires_at_hh: "9", expires_at_mm: "1", expires_at_meridiem: "am"
      }
    end

    it "is valid" do
      expect(subject).to be_valid
      expect(subject.vacancy.expires_on).to eq(Date.current + 1.week)
      expect(subject.vacancy.publish_on).to eq(Date.current)
      expect(subject.vacancy.starts_on).to eq(Date.current + 1.month)
    end
  end
end
