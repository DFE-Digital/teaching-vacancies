require "rails_helper"

RSpec.describe StepProcess do
  subject { described_class.new(current_step, step_groups) }

  let(:current_step) { :two }
  let(:step_groups) do
    {
      alpha: %i[one],
      beta: %i[two three],
      gamma: nil,
      delta: %i[four five six],
      epsilon: [],
    }
  end

  describe "#initialize" do
    it "makes sure the current step is included in all steps" do
      expect { described_class.new(:seven, step_groups) }.to raise_error(MissingStepError)
    end
  end

  describe "#step_groups" do
    it "excludes step groups without steps" do
      expect(subject.step_groups).to eq({
        alpha: %i[one],
        beta: %i[two three],
        delta: %i[four five six],
      })
    end
  end

  describe "#steps" do
    it "returns all the steps in order" do
      expect(subject.steps).to eq(%i[one two three four five six])
    end
  end

  describe "#current_step_group" do
    it "returns the current step group" do
      expect(subject.current_step_group).to eq(:beta)
    end
  end

  describe "#steps_in_current_group" do
    it "returns all steps in the current group" do
      expect(subject.steps_in_current_group).to eq(%i[two three])
    end
  end

  describe "#current_step_group_number" do
    it "returns the position of the current step group" do
      expect(subject.current_step_group_number).to eq(2)
    end
  end

  describe "#total_step_groups" do
    it "returns the total number of step groups" do
      expect(subject.total_step_groups).to eq(3)
    end
  end

  describe "#first_of_group?" do
    context "when on the first step of a group" do
      let(:current_step) { :four }

      it { is_expected.to be_first_of_group }
    end

    context "when on another step" do
      let(:current_step) { :five }

      it { is_expected.not_to be_first_of_group }
    end
  end

  describe "#last_of_group?" do
    context "when on the last step of a group" do
      let(:current_step) { :six }

      it { is_expected.to be_last_of_group }
    end

    context "when on another step" do
      let(:current_step) { :five }

      it { is_expected.not_to be_last_of_group }
    end
  end

  describe "#next_step" do
    it "returns the next step" do
      expect(subject.next_step).to eq(:three)
    end

    context "when on the last step" do
      let(:current_step) { :six }

      it "returns nil" do
        expect(subject.next_step).to be_nil
      end
    end
  end

  describe "#previous_step" do
    it "returns the previous step" do
      expect(subject.previous_step).to eq(:one)
    end

    context "when on the first step" do
      let(:current_step) { :one }

      it "returns nil" do
        expect(subject.previous_step).to be_nil
      end
    end
  end

  describe "#first_step?" do
    context "when on the first step" do
      let(:current_step) { :one }

      it { is_expected.to be_first_step }
    end

    context "when on another step" do
      let(:current_step) { :four }

      it { is_expected.not_to be_first_step }
    end
  end

  describe "#last_step?" do
    context "when on the last step" do
      let(:current_step) { :six }

      it { is_expected.to be_last_step }
    end

    context "when on another step" do
      let(:current_step) { :three }

      it { is_expected.not_to be_last_step }
    end
  end
end
