require "rails_helper"

RSpec.describe Search::KeywordCorrection do
  before do
    create(:vacancy, :past_publish, job_title: "Geography teacher", subjects: %w[Geography])
    create(:vacancy, :past_publish, job_title: "Art assistant", subjects: [])
  end

  describe "#call" do
    it "corrects a misspelt word" do
      expect(described_class.new("geografy").call).to eq("geography")
    end

    it "corrects only the misspelt words" do
      expect(described_class.new("Geografy teacher").call).to eq("geography teacher")
    end

    it "returns nil when the keyword is spelt correctly" do
      expect(described_class.new("geography").call).to be_nil
    end

    it "returns nil when nothing similar is found" do
      expect(described_class.new("xylophone").call).to be_nil
    end

    it "leaves short words alone" do
      expect(described_class.new("arc").call).to be_nil
    end

    it "returns nil when there is no keyword" do
      expect(described_class.new(nil).call).to be_nil
    end

    it "ignores vacancies that are not live" do
      create(:vacancy, :expired, job_title: "Xylophone tutor")

      expect(described_class.new("xylophon").call).to be_nil
    end
  end
end
