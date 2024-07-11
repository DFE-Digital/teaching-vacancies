require "rails_helper"

class DummyExport
  include Vacancies::Export::DwpFindAJob::Versioning
end

RSpec.describe Vacancies::Export::DwpFindAJob::Versioning do
  let(:vacancy) { build_stubbed(:vacancy, publish_on: publish_date) }

  before { travel_to(Time.zone.local(2024, 5, 2, 1, 4, 44)) }
  after { travel_back }

  describe "#version" do
    subject(:version) { DummyExport.new.version(vacancy) }

    context "when the vacancy does not have publishing date set" do
      let(:publish_date) { nil }

      it "returns nil" do
        expect(version).to be_nil
      end
    end

    context "when the vacancy publishing date is empty" do
      let(:publish_date) { "" }

      it "returns nil" do
        expect(version).to be_nil
      end
    end

    context "when the vacancy publishing date is in the future" do
      let(:publish_date) { 1.day.from_now }

      it "returns nil" do
        expect(version).to be_nil
      end
    end

    context "when the vacancy publishing date is today" do
      let(:publish_date) { Date.current }

      it "returns 0" do
        expect(version).to eq(0)
      end
    end

    context "when the vacancy was published less than 31 days ago" do
      let(:publish_date) { 30.days.ago }

      it "returns 0" do
        expect(version).to eq(0)
      end
    end

    context "when the vacancy was published 31 days ago" do
      let(:publish_date) { 31.days.ago }

      it "returns 1" do
        expect(version).to eq(1)
      end
    end

    context "when the vacancy was published 61 days ago" do
      let(:publish_date) { 61.days.ago }

      it "returns 1" do
        expect(version).to eq(1)
      end
    end

    context "when the vacancy was published 62 days ago" do
      let(:publish_date) { 62.days.ago }

      it "returns 2" do
        expect(version).to eq(2)
      end
    end

    context "when the vacancy was published 92 days ago" do
      let(:publish_date) { 92.days.ago }

      it "returns 2" do
        expect(version).to eq(2)
      end
    end

    context "when the vacancy was published 93 days ago" do
      let(:publish_date) { 93.days.ago }

      it "returns 3" do
        expect(version).to eq(3)
      end
    end

    context "when the vacancy was published 372 days ago" do
      let(:publish_date) { 372.days.ago }

      it "returns 12" do
        expect(version).to eq(12)
      end
    end
  end

  describe "#versioned_reference" do
    subject(:versioned_reference) { DummyExport.new.versioned_reference(vacancy) }

    context "when the vacancy does not have publishing date set" do
      let(:publish_date) { nil }

      it "returns nil" do
        expect(versioned_reference).to be_nil
      end
    end

    context "when the vacancy publishing date is empty" do
      let(:publish_date) { "" }

      it "returns nil" do
        expect(versioned_reference).to be_nil
      end
    end

    context "when the vacancy publishing date is in the future" do
      let(:publish_date) { 1.day.from_now }

      it "returns nil" do
        expect(versioned_reference).to be_nil
      end
    end

    context "when the vacancy publishing date is today" do
      let(:publish_date) { Date.current }

      it "returns the vacancy id" do
        expect(versioned_reference).to eq(vacancy.id)
      end
    end

    context "when the vacancy was published less than 31 days ago" do
      let(:publish_date) { 30.days.ago }

      it "returns the vacancy id" do
        expect(versioned_reference).to eq(vacancy.id)
      end
    end

    context "when the vacancy was published 31 days ago" do
      let(:publish_date) { 31.days.ago }

      it "returns the vacancy id with a suffix version: '-1'" do
        expect(versioned_reference).to eq("#{vacancy.id}-1")
      end
    end

    context "when the vacancy was published 61 days ago" do
      let(:publish_date) { 61.days.ago }

      it "returns the vacancy id with a suffix version: '-1'" do
        expect(versioned_reference).to eq("#{vacancy.id}-1")
      end
    end

    context "when the vacancy was published 62 days ago" do
      let(:publish_date) { 62.days.ago }

      it "returns the vacancy id with a suffix version: '-2'" do
        expect(versioned_reference).to eq("#{vacancy.id}-2")
      end
    end

    context "when the vacancy was published 92 days ago" do
      let(:publish_date) { 92.days.ago }

      it "returns the vacancy id with a suffix version: '-2'" do
        expect(versioned_reference).to eq("#{vacancy.id}-2")
      end
    end

    context "when the vacancy was published 93 days ago" do
      let(:publish_date) { 93.days.ago }

      it "returns the vacancy id with a suffix version: '-3'" do
        expect(versioned_reference).to eq("#{vacancy.id}-3")
      end
    end

    context "when the vacancy was published 372 days ago" do
      let(:publish_date) { 372.days.ago }

      it "returns the vacancy id with a suffix version: '-12'" do
        expect(versioned_reference).to eq("#{vacancy.id}-12")
      end
    end
  end
end
