require "rails_helper"

RSpec.describe Search::Postgres::TsvectorGenerator do
  subject { described_class.new(weighted_values) }

  let(:vacancy) { build_stubbed(:vacancy, job_title: "Hello") }

  context "when initialized with invalid keys" do
    let(:weighted_values) { { a: [], b: [], e: [] } }

    it "raises an error" do
      expect { subject }.to raise_error(ArgumentError)
    end
  end

  describe "#tsvector" do
    let(:weighted_values) { { a: ["Teaching"], c: "Hello World" } }

    it "generates an appropriate tsvector value" do
      expect(subject.tsvector).to include("'teaching':1A")
      expect(subject.tsvector).to include("'hello':1C")
      expect(subject.tsvector).to include("'world':2C")
    end
  end
end
