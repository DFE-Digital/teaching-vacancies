require "rails_helper"

RSpec.describe StringAnonymiser do
  subject { described_class.new("Hello world!") }

  describe "#to_s" do
    it "returns an anonymised form of the input string" do
      expect(subject.to_s).to eq("xubah-fylag-ramor-laluz-tigyd-nigyb-hybek-ryvym-nysog-vodif-zyrus-bulos-zezer-ruzuz-fyket-nenac-pyxyx")
    end
  end

  describe "#==" do
    let(:same) { described_class.new("Hello world!") }
    let(:different_raw_string) { described_class.new("Goodbye world!") }
    let(:not_an_anonymiser) { "Hello world!" }

    it "returns whether the other instance is a StringAnonymiser with the same raw string" do
      expect(subject).to eq(same)
      expect(subject).not_to eq(different_raw_string)
      expect(subject).not_to eq(not_an_anonymiser)
    end
  end
end
