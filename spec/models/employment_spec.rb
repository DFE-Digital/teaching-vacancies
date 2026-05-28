require "rails_helper"

RSpec.describe Employment do
  let(:employment) { described_class.new(params.merge(employment_type: :job, job_application: build(:job_application))) }
  let(:params) { {} }

  describe "validations" do
    subject { employment }

    it { is_expected.to validate_presence_of(:organisation) }
    it { is_expected.to validate_presence_of(:job_title) }
    it { is_expected.to validate_presence_of(:main_duties) }

    context "when main duties exceeds the word limit" do
      let(:params) { valid_params.merge(main_duties: words(EmploymentRecord::MAIN_DUTIES_MAX_WORDS + 1)) }

      it "is invalid" do
        expect(employment).not_to be_valid
        expect(employment.errors.messages[:main_duties_words]).to eq(["Main duties must be 150 words or less"])
      end
    end

    context "when reason for leaving exceeds the word limit" do
      let(:params) { valid_params.merge(reason_for_leaving: words(EmploymentRecord::REASON_FOR_LEAVING_MAX_WORDS + 1)) }

      it "is invalid" do
        expect(employment).not_to be_valid
        expect(employment.errors.messages[:reason_for_leaving_words]).to eq(["Reason for leaving role must be 50 words or less"])
      end
    end
  end

  describe "#duplicate" do
    subject(:duplicate) { employment.duplicate }
    let(:employment) { create(:employment) }

    it "returns a new Employment with the same attributes" do
      %i[
        is_current_role
        employment_type
        ended_on
        job_title
        main_duties
        organisation
        reason_for_break
        started_on
        subjects
      ].each do |attribute|
        expect(duplicate.public_send(attribute)).to eq(employment.public_send(attribute))
      end
    end

    it "returns a new unsaved Employment" do
      expect(duplicate).to be_new_record
    end

    it "does not copy job application associations" do
      expect(duplicate.job_application).to be_nil
    end
  end

  describe "#started_on" do
    context "when started_on is blank" do
      let(:params) { {} }

      it "is invalid" do
        expect(employment).not_to be_valid
        expect(employment.errors.of_kind?(:started_on, :blank)).to be true
      end
    end

    context "when started_on is an invalid date" do
      let(:params) { { "started_on(1i)" => "2021", "started_on(2i)" => "01", "started_on(3i)" => "99" } }

      it "is invalid" do
        expect { employment }.to raise_error(ActiveRecord::MultiparameterAssignmentErrors)
      end
    end

    context "when started_on is an incomplete date" do
      let(:params) { { "started_on(3i)" => "1" } }

      it "is invalid" do
        expect(employment).not_to be_valid
        expect(employment.errors.messages[:ended_on]).to eq(["Enter the date you left this school or organisation"])
      end
    end

    context "when started_on is after today" do
      let(:params) { { "started_on(1i)" => "2121", "started_on(2i)" => "01", "started_on(3i)" => "01" } }

      it "is invalid" do
        expect(employment).not_to be_valid
        expect(employment.errors.of_kind?(:started_on, :before)).to be true
      end
    end
  end

  describe "#ended_on" do
    context "when ended_on is blank" do
      let(:params) { { is_current_role: false } }

      it "is invalid" do
        expect(employment).not_to be_valid
        expect(employment.errors.of_kind?(:ended_on, :blank)).to be true
      end
    end

    context "when ended_on is invalid" do
      let(:params) { { is_current_role: false, "ended_on(1i)" => "2021", "ended_on(2i)" => "01", "ended_on(3i)" => "40" } }

      it "is invalid" do
        expect { employment }.to raise_error(ActiveRecord::MultiparameterAssignmentErrors)
      end
    end

    context "when ended_on is an incomplete date" do
      let(:params) do
        { is_current_role: false,
          "ended_on(3i)" => "10",
          "started_on(1i)" => "2021",
          "started_on(2i)" => "01",
          "started_on(3i)" => "01" }
      end

      it "is invalid" do
        expect(employment).not_to be_valid
        expect(employment.errors.messages[:ended_on]).to eq(["Enter the date you left this school or organisation"])
      end
    end

    context "when ended_on is after today" do
      let(:params) do
        { is_current_role: false,
          "started_on(1i)" => "2021",
          "started_on(2i)" => "01",
          "started_on(3i)" => "01",
          "ended_on(1i)" => "2120",
          "ended_on(2i)" => "01",
          "ended_on(3i)" => "01" }
      end

      it "is invalid" do
        expect(employment).not_to be_valid
        expect(employment.errors.of_kind?(:ended_on, :before)).to be true
      end
    end

    context "when ended_on and current role are both set" do
      let(:params) do
        { is_current_role: true,
          organisation: "An organisation",
          job_title: "A job title",
          main_duties: "Some main duties",
          reason_for_leaving: "stress",
          "started_on(1i)" => "2021",
          "started_on(2i)" => "01",
          "started_on(3i)" => "01",
          "ended_on(1i)" => "2022",
          "ended_on(2i)" => "01",
          "ended_on(3i)" => "01" }
      end

      it "is invalid" do
        expect(employment).not_to be_valid
        expect(employment.errors.messages).to eq({ ended_on: ["End date cannot be entered for current role"] })
      end
    end

    context "when ended_on is before started_on" do
      let(:params) do
        { is_current_role: false,
          "started_on(1i)" => "2021",
          "started_on(2i)" => "01",
          "started_on(3i)" => "01",
          "ended_on(1i)" => "2020",
          "ended_on(2i)" => "01",
          "ended_on(3i)" => "01" }
      end

      it "is invalid" do
        expect(employment).not_to be_valid
        expect(employment.errors.of_kind?(:ended_on, :on_or_after)).to be true
      end
    end
  end

  context "when all attributes are valid" do
    let(:params) { valid_params }

    it "is valid" do
      expect(employment).to be_valid
    end

    context "when ended_on is on the same date as started_on" do
      let(:params) do
        { organisation: "An organisation",
          job_title: "A job title",
          main_duties: "Some main duties",
          is_current_role: false,
          "started_on(1i)" => "2019",
          "started_on(2i)" => "09",
          "started_on(3i)" => "30",
          "ended_on(1i)" => "2019",
          "ended_on(2i)" => "09",
          "ended_on(3i)" => "30",
          reason_for_leaving: "stress" }
      end

      it "is valid" do
        expect(employment).to be_valid
      end
    end
  end

  def valid_params
    { organisation: "An organisation",
      job_title: "A job title",
      main_duties: "Some main duties",
      is_current_role: false,
      "started_on(1i)" => "2019",
      "started_on(2i)" => "09",
      "started_on(3i)" => "01",
      "ended_on(1i)" => "2020",
      "ended_on(2i)" => "07",
      "ended_on(3i)" => "30",
      reason_for_leaving: "stress" }
  end

  def words(count)
    Array.new(count, "word").join(" ")
  end
end
