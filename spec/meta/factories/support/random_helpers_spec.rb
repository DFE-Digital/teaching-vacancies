require "rails_helper"

RSpec.describe RandomHelpers do
  let(:range) { 2..5 }
  let(:things) { %i[a b c] }

  describe "#factory_rand(range)" do
    context "when in test mode" do
      it "uses the minimum of the range every time" do
        expect(described_class.factory_rand(range)).to eq(2)
      end
    end

    context "when not in test mode" do
      before do
        allow(Rails.env).to receive(:test?).and_return(false)
      end

      it "picks a random number from the range" do
        expect(RandomHelpers).to receive(:rand).with(range).and_call_original
        described_class.factory_rand(range)
      end
    end
  end

  describe "#factory_sample(things, num = nil)" do
    context "when in test mode" do
      context "when `num` is not given" do
        it "returns the first thing" do
          expect(described_class.factory_sample(things)).to eq(:a)
        end
      end

      context "when `num` is nil" do
        it "returns the first thing" do
          expect(described_class.factory_sample(things, nil)).to eq(:a)
        end
      end

      context "when `num` is 1" do
        it "returns the first thing" do
          expect(described_class.factory_sample(things, 1)).to eq(:a)
        end
      end

      context "when `num` is > 1" do
        it "returns an array of the first `num` things" do
          expect(described_class.factory_sample(things, 2)).to eq(%i[a b])
        end
      end
    end

    context "when not in test mode" do
      before do
        allow(Rails.env).to receive(:test?).and_return(false)
      end

      context "when `num` is not given" do
        it "returns a random thing" do
          expect(things).to receive(:sample).and_call_original
          expect(things).to include(described_class.factory_sample(things))
        end
      end

      context "when `num` is nil" do
        it "returns a random thing" do
          expect(things).to receive(:sample).and_call_original
          expect(things).to include(described_class.factory_sample(things))
        end
      end

      context "when `num` is 1" do
        it "returns an array of a random thing" do
          expect(things).to receive(:sample).with(1).and_call_original

          result = described_class.factory_sample(things, 1)
          expect(result.size).to eq(1)
          expect(things & result).to eq(result)
        end
      end

      context "when `num` is > 1" do
        it "returns an array of a random things" do
          expect(things).to receive(:sample).with(2).and_call_original

          result = described_class.factory_sample(things, 2)
          expect(result.size).to eq(2)
          expect((things & result).sort).to eq(result.sort)
        end
      end
    end
  end

  describe "#factory_rand_sample(things, range)" do
    let(:random_number) { double }

    it "combines `factory_rand` and `factory_sample`" do
      expect(described_class).to receive(:factory_rand)
        .with(range)
        .and_return(random_number)

      expect(described_class).to receive(:factory_sample)
        .with(things, random_number)

      described_class.factory_rand_sample(things, range)
    end
  end
end
