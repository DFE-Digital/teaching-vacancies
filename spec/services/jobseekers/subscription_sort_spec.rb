require "rails_helper"

RSpec.describe Jobseekers::SubscriptionSort do
  subject { described_class.new }

  describe "#initialize" do
    it "sets the column and order of the first sort option by default" do
      expect(subject.sort_by).to eq "created_at"
      expect(subject.order).to eq "desc"
    end
  end

  describe "#update" do
    context "when the sort column is valid" do
      let(:sort_by) { "frequency" }

      it "updates the sort column" do
        expect(subject.update(sort_by:).sort_by).to eq "frequency"
      end

      it "updates the sort order" do
        expect(subject.update(sort_by:).order).to eq "asc"
      end
    end

    context "when the column is invalid" do
      let(:sort_by) { "something_nasty" }

      it "does not update the sort column" do
        expect(subject.update(sort_by:).sort_by).to eq "created_at"
      end

      it "does not update the sort order" do
        expect(subject.update(sort_by:).order).to eq "desc"
      end
    end

    context "when the column is blank" do
      let(:sort_by) { nil }

      it "does not update the sort column" do
        expect(subject.update(sort_by:).sort_by).to eq "created_at"
      end

      it "does not update the sort order" do
        expect(subject.update(sort_by:).order).to eq "desc"
      end
    end
  end
end
