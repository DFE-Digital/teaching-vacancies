require "rails_helper"

RSpec.describe Jobseekers::JobApplication::Details::EmploymentForm, type: :model do
  subject { described_class.new(params) }

  let(:params) { {} }

  it { is_expected.to validate_presence_of(:organisation) }
  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_presence_of(:main_duties) }
  it { is_expected.to validate_inclusion_of(:current_role).in_array(%w[yes no]) }

  describe "#started_on" do
    context "when started_on is blank" do
      let(:params) { {} }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:started_on, :blank)).to be true
      end
    end

    context "when started_on is an invalid date" do
      let(:params) { { "started_on(1i)" => "2021", "started_on(2i)" => "01", "started_on(3i)" => "100" } }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:started_on, :invalid)).to be true
      end
    end

    context "when started_on is an incomplete date" do
      let(:params) { { "started_on(3i)" => "1" } }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:started_on, :invalid)).to be true
      end
    end

    context "when started_on is after today" do
      let(:params) { { "started_on(1i)" => "2121", "started_on(2i)" => "01", "started_on(3i)" => "01" } }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:started_on, :before)).to be true
      end
    end
  end

  describe "#ended_on" do
    context "when ended_on is blank" do
      let(:params) { { current_role: "no" } }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:ended_on, :blank)).to be true
      end
    end

    context "when ended_on is invalid" do
      let(:params) { { current_role: "no", "ended_on(1i)" => "2021", "ended_on(2i)" => "01", "ended_on(3i)" => "100" } }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:ended_on, :invalid)).to be true
      end
    end

    context "when ended_on is an incomplete date" do
      let(:params) do
        { current_role: "no",
          "ended_on(3i)" => "10",
          "started_on(1i)" => "2021", "started_on(2i)" => "01", "started_on(3i)" => "01" }
      end

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:ended_on, :invalid)).to be true
      end
    end

    context "when ended_on is after today" do
      let(:params) do
        { current_role: "no",
          "started_on(1i)" => "2021", "started_on(2i)" => "01", "started_on(3i)" => "01",
          "ended_on(1i)" => "2120", "ended_on(2i)" => "01", "ended_on(3i)" => "01" }
      end

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:ended_on, :before)).to be true
      end
    end

    context "when ended_on is before started_on" do
      let(:params) do
        { current_role: "no",
          "started_on(1i)" => "2021", "started_on(2i)" => "01", "started_on(3i)" => "01",
          "ended_on(1i)" => "2020", "ended_on(2i)" => "01", "ended_on(3i)" => "01" }
      end

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:ended_on, :after)).to be true
      end
    end
  end

  context "when all attributes are valid" do
    let(:params) do
      { organisation: "An organisation", job_title: "A job title", main_duties: "Some main duties",
        current_role: "no", "started_on(1i)" => "2019", "started_on(2i)" => "09", "started_on(3i)" => "01",
        "ended_on(1i)" => "2020", "ended_on(2i)" => "07", "ended_on(3i)" => "30", reason_for_leaving: "stress" }
    end

    it "is valid" do
      expect(subject).to be_valid
    end
  end
end
