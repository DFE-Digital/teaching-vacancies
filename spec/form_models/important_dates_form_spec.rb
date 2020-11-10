require "rails_helper"

RSpec.describe ImportantDatesForm, type: :model do
  subject { ImportantDatesForm.new({}) }

  context "validations" do
    it {
      should validate_presence_of(:publish_on).with_message(
        I18n.t("activerecord.errors.models.vacancy.attributes.publish_on.blank"),
      )
    }
    it {
      should validate_presence_of(:expires_on).with_message(
        I18n.t("activerecord.errors.models.vacancy.attributes.expires_on.blank"),
      )
    }
    it {
      should validate_presence_of(:expires_at).with_message(
        I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.blank"),
      )
    }

    describe "#publish_on" do
      let(:important_dates) { ImportantDatesForm.new(publish_on: Time.zone.yesterday) }

      it "must be in the future" do
        expect(important_dates.valid?).to be false
        expect(important_dates.errors.messages[:publish_on])
          .to include(I18n.t("activerecord.errors.models.vacancy.attributes.publish_on.before_today"))
      end
    end

    describe "#expires_on" do
      it "must be in the future" do
        important_dates = ImportantDatesForm.new(expires_on: 1.day.ago)
        expect(important_dates.valid?).to be false

        expect(important_dates.errors.messages[:expires_on])
          .to include(I18n.t("activerecord.errors.models.vacancy.attributes.expires_on.before_today"))
      end

      it "must be after publish_on" do
        important_dates = ImportantDatesForm.new(expires_on: Date.current,
                                                 publish_on: Time.zone.tomorrow)
        expect(important_dates.valid?).to be false

        expect(important_dates.errors.messages[:expires_on])
          .to include(I18n.t("activerecord.errors.models.vacancy.attributes.expires_on.before_publish_on"))
      end
    end

    describe "#starts_on" do
      it "has no validation applied when blank" do
        important_dates = ImportantDatesForm.new(starts_on: nil)
        important_dates.valid?

        expect(important_dates.errors.messages[:starts_on]).to be_empty
      end

      it "must be in the future" do
        important_dates = ImportantDatesForm.new(starts_on: 1.day.ago)
        expect(important_dates.valid?).to be false

        expect(important_dates.errors.messages[:starts_on])
          .to include(I18n.t("activerecord.errors.models.vacancy.attributes.starts_on.before_today"))
      end

      it "must be after publish_on" do
        important_dates = ImportantDatesForm.new(starts_on: Date.current,
                                                 publish_on: Time.zone.tomorrow)
        expect(important_dates.valid?).to be false

        expect(important_dates.errors.messages[:starts_on])
          .to include(I18n.t("activerecord.errors.models.vacancy.attributes.starts_on.before_publish_on"))
      end

      it "must be after expires_on" do
        important_dates = ImportantDatesForm.new(starts_on: Date.current,
                                                 expires_on: Time.zone.tomorrow)
        expect(important_dates.valid?).to be false

        expect(important_dates.errors.messages[:starts_on])
          .to include(I18n.t("activerecord.errors.models.vacancy.attributes.starts_on.before_expires_on"))
      end
    end

    describe "#expires_at" do
      before(:each) do
        subject.expires_at_hh = "11"
        subject.expires_at_mm = "11"
        subject.expires_at_meridiem = "am"
      end

      it "displays error if all fields are blank" do
        subject.expires_at_hh = nil
        subject.expires_at_mm = nil
        subject.expires_at_meridiem = nil
        subject.valid?
        expect(subject.errors.messages[:expires_at]).to include(
          I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.blank"),
        )
      end

      validate_expires_at_hours = [
        { value: nil, errors: I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.blank") },
        { value: "not a number",
          errors: I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.wrong_format") },
        { value: "14", errors: I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.wrong_format") },
        { value: "0", errors: I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.wrong_format") },
      ]

      validate_expires_at_hours.each do |h|
        it "displays '#{h[:errors][0]}' error when hours field is #{h[:value]}" do
          subject.expires_at_hh = h[:value]
          subject.valid?
          expect(subject.errors.messages[:expires_at]).to include(h[:errors])
        end
      end

      validate_expires_at_minutes = [
        { value: nil, errors: I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.blank") },
        { value: "not a number",
          errors: I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.wrong_format") },
        { value: "-6", errors: I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.wrong_format") },
        { value: "66", errors: I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.wrong_format") },
      ]

      validate_expires_at_minutes.each do |m|
        it "displays '#{m[:errors][0]}' error when minutes field is #{m[:value]}" do
          subject.expires_at_mm = m[:value]
          subject.valid?
          expect(subject.errors.messages[:expires_at]).to include(m[:errors])
        end
      end

      it "displays error if am/pm field is blank" do
        subject.expires_at_meridiem = ""
        subject.valid?
        expect(subject.errors.messages[:expires_at]).to eq(
          [I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.must_be_am_pm")],
        )
      end

      it "displays wrong format error if minutes and meridiem are invalid" do
        subject.expires_at_mm = "66"
        subject.expires_at_meridiem = nil
        subject.valid?
        expect(subject.errors.messages[:expires_at]).to include(
          I18n.t("activerecord.errors.models.vacancy.attributes.expires_at.wrong_format"),
        )
      end

      it "does not display error if all fields are correct" do
        subject.expires_at_hh = "01"
        subject.expires_at_mm = "01"
        subject.expires_at_meridiem = "am"
        subject.valid?
        expect(subject.errors.messages[:expires_at]).to be_empty
      end

      it "can display 24 hours format in 12 hours format AM" do
        important_dates = ImportantDatesForm.new(expires_at: Time.parse("6:34").getlocal)
        expect(important_dates.expires_at_hh).to eq("6")
        expect(important_dates.expires_at_mm).to eq("34")
        expect(important_dates.expires_at_meridiem).to eq("am")
        expect(subject.errors.messages[:expires_at]).to be_empty
      end

      it "can display 24 hours format in 12 hours format PM" do
        important_dates = ImportantDatesForm.new(expires_at: Time.parse("18:00").getlocal)
        expect(important_dates.expires_at_hh).to eq("6")
        expect(important_dates.expires_at_mm).to eq("0")
        expect(important_dates.expires_at_meridiem).to eq("pm")
        expect(subject.errors.messages[:expires_at]).to be_empty
      end
    end
  end

  context "when expiry time components are given" do
    it "cannot save expiry time if fields are incomplete" do
      important_dates = ImportantDatesForm.new(expires_at_hh: "9")

      expect(important_dates.params_to_save).not_to include(expires_at_hh: "9")
    end

    it "can save expiry time if time fields are complete" do
      important_dates = ImportantDatesForm.new(expires_on: 1.week.from_now,
                                               expires_at_hh: "9",
                                               expires_at_mm: "15",
                                               expires_at_meridiem: "am")
      params = important_dates.params_to_save
      expect(params.count).to eq(2)
      expect(params[:expires_at].hour).to eq(9)
      expect(params[:expires_at].min).to eq(15)
    end
  end

  context "when all attributes are valid" do
    it "can correctly be converted to a vacancy" do
      important_dates = ImportantDatesForm.new(state: "create",
                                               expires_on: 1.week.from_now,
                                               publish_on: Date.current,
                                               starts_on: 1.month.from_now,
                                               expires_at_hh: "9", expires_at_mm: "1", expires_at_meridiem: "am")

      expect(important_dates.valid?).to be true
      expect(important_dates.vacancy.expires_on).to eq(Date.current + 1.week)
      expect(important_dates.vacancy.publish_on).to eq(Date.current)
      expect(important_dates.vacancy.starts_on).to eq(Date.current + 1.month)
    end
  end
end
