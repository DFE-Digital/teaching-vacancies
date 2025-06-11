require "rails_helper"

RSpec.describe Publishers::JobListing::ImportantDatesForm, type: :model do
  subject { described_class.new(params, vacancy) }

  let(:vacancy) { build_stubbed(:vacancy, publish_on: publish_on) }

  let(:publish_on_day) { "another_day" }
  let(:publish_on) { 6.months.from_now }
  let(:expires_at) { 1.year.from_now }

  let(:params) do
    {
      publish_on_day: publish_on_day,
      "publish_on(1i)" => publish_on.year.to_s,
      "publish_on(2i)" => publish_on.month.to_s,
      "publish_on(3i)" => publish_on.day.to_s,
      "expires_at(1i)" => expires_at.year.to_s,
      "expires_at(2i)" => expires_at.month.to_s,
      "expires_at(3i)" => expires_at.day.to_s,
      expiry_time: "9:00",
    }
  end

  context "when all attributes are valid" do
    it "is valid" do
      expect(subject).to be_valid
    end
  end

  it { is_expected.to validate_inclusion_of(:expiry_time).in_array(Vacancy::EXPIRY_TIME_OPTIONS) }

  context "when publish_on_day and publish_on are not defined" do
    let(:publish_on_day) { "" }

    before do
      params["publish_on(1i)"] = ""
      params["publish_on(2i)"] = ""
      params["publish_on(3i)"] = ""
    end

    it "is invalid" do
      expect(subject).not_to be_valid
      expect(subject.errors.of_kind?(:publish_on_day, :inclusion)).to be true
    end

    it "is not included in the parameters to save" do
      expect(subject.params_to_save).not_to have_key(:publish_on)
    end
  end

  describe "publish_on" do
    context "when date is blank" do
      before do
        params["publish_on(1i)"] = ""
        params["publish_on(2i)"] = ""
        params["publish_on(3i)"] = ""
      end

      context "when vacancy is published and publish_on is on or before today" do
        let(:vacancy) { build_stubbed(:vacancy, :past_publish) }

        it "is valid" do
          expect(subject).to be_valid
        end

        it "is not included in the parameters to save" do
          expect(subject.params_to_save).not_to have_key(:publish_on)
        end
      end

      context "when vacancy is published and publish_on is in the future" do
        let(:vacancy) { build_stubbed(:vacancy, :published, publish_on: Date.current + 1.day) }

        it "is invalid" do
          expect(subject).to be_invalid
          expect(subject.errors.of_kind?(:publish_on, :blank)).to be true
        end

        it "is not included in the parameters to save" do
          expect(subject.params_to_save).not_to have_key(:publish_on)
        end
      end

      context "when vacancy is not published" do
        let(:vacancy) { build_stubbed(:draft_vacancy) }

        it "is invalid" do
          expect(subject).to be_invalid
          expect(subject.errors.of_kind?(:publish_on, :blank)).to be true
        end

        it "is not included in the parameters to save" do
          expect(subject.params_to_save).not_to have_key(:publish_on)
        end
      end
    end

    context "when date is incomplete" do
      before { params["publish_on(2i)"] = "" }

      context "when vacancy is published and publish_on is on or before today" do
        let(:vacancy) { build_stubbed(:vacancy, :past_publish) }

        it "is valid" do
          expect(subject).to be_valid
        end

        it "is not included in the parameters to save" do
          expect(subject.params_to_save).not_to have_key(:publish_on)
        end
      end

      context "when vacancy is published and publish_on is in the future" do
        let(:vacancy) { build_stubbed(:vacancy, :published, publish_on: Date.current + 1.day) }

        it "is invalid" do
          expect(subject).to be_invalid
          expect(subject.errors.of_kind?(:publish_on, :invalid)).to be true
        end

        it "is not included in the parameters to save" do
          expect(subject.params_to_save).not_to have_key(:publish_on)
        end
      end

      context "when vacancy is not published" do
        let(:vacancy) { build_stubbed(:draft_vacancy) }

        it "is invalid" do
          expect(subject).to be_invalid
          expect(subject.errors.of_kind?(:publish_on, :invalid)).to be true
        end

        it "is not included in the parameters to save" do
          expect(subject.params_to_save).not_to have_key(:publish_on)
        end
      end
    end

    context "when date is invalid" do
      before { params["publish_on(2i)"] = "100" }

      context "when vacancy is published and publish_on is on or before today" do
        let(:vacancy) { build_stubbed(:vacancy, :past_publish) }

        it "is valid" do
          expect(subject).to be_valid
        end

        it "is not included in the parameters to save" do
          expect(subject.params_to_save).not_to have_key(:publish_on)
        end
      end

      context "when vacancy is published and publish_on is in the future" do
        let(:vacancy) { build_stubbed(:vacancy, :published, publish_on: Date.current + 1.day) }

        it "is invalid" do
          expect(subject).to be_invalid
          expect(subject.errors.of_kind?(:publish_on, :invalid)).to be true
        end

        it "is not included in the parameters to save" do
          expect(subject.params_to_save).not_to have_key(:publish_on)
        end
      end

      context "when vacancy is not published" do
        let(:vacancy) { build_stubbed(:draft_vacancy) }

        it "is invalid" do
          expect(subject).to be_invalid
          expect(subject.errors.of_kind?(:publish_on, :invalid)).to be true
        end

        it "is not included in the parameters to save" do
          expect(subject.params_to_save).not_to have_key(:publish_on)
        end
      end
    end

    context "when date is not in the future" do
      let(:publish_on) { 1.year.ago.to_date }

      context "when vacancy is published" do
        let(:vacancy) { build_stubbed(:vacancy, :published) }

        it "is valid" do
          expect(subject).to be_valid
        end

        it "is not included in the parameters to save" do
          expect(subject.params_to_save).not_to have_key(:publish_on)
        end
      end

      context "when vacancy is not published" do
        let(:vacancy) { build_stubbed(:draft_vacancy) }

        it "is invalid" do
          expect(subject).to be_invalid
          expect(subject.errors.of_kind?(:publish_on, :on_or_after)).to be true
        end

        it "is included in the parameters to save" do
          expect(subject.params_to_save).to have_key(:publish_on)
          expect(subject.params_to_save[:publish_on]).to eq(publish_on)
        end
      end
    end

    context "when date is too far in the future" do
      let(:publish_on) { 25.months.from_now.to_date }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:publish_on, :on_or_before)).to be true
      end

      it "is included in the parameters to save" do
        expect(subject.params_to_save).to have_key(:publish_on)
        expect(subject.params_to_save[:publish_on]).to eq(publish_on)
      end
    end
  end

  describe "expires_at" do
    context "when date is blank" do
      before do
        params["expires_at(1i)"] = ""
        params["expires_at(2i)"] = ""
        params["expires_at(3i)"] = ""
      end

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:expires_at, :blank)).to be true
      end
    end

    context "when date is incomplete" do
      before { params["expires_at(2i)"] = "" }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:expires_at, :invalid)).to be true
      end
    end

    context "when date is invalid" do
      before { params["expires_at(2i)"] = "100" }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:expires_at, :invalid)).to be true
      end
    end

    context "when date is not in the future" do
      let(:expires_at) { 1.month.ago }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:expires_at, :on_or_after)).to be true
      end
    end

    context "when date is too far in the future" do
      let(:expires_at) { 25.months.from_now }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:expires_at, :on_or_before)).to be true
      end
    end

    context "when date is before publish_on" do
      let(:expires_at) { 3.months.from_now }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:expires_at, :after)).to be true
      end
    end
  end
end
