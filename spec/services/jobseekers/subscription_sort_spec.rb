require "rails_helper"

RSpec.describe Jobseekers::SubscriptionSort do
  subject { described_class.new }

  describe "#initialize" do
    it "sets the column and order of the first sort option by default" do
      expect(subject.column).to eq "created_at"
      expect(subject.order).to eq "desc"
    end
  end

  describe "#update" do
    context "when the sort column is valid" do
      let(:column) { "frequency" }

      it "updates the sort column" do
        expect(subject.update(column: column).column).to eq "frequency"
      end

      it "updates the sort order" do
        expect(subject.update(column: column).order).to eq "asc"
      end
    end

    context "when the column is invalid" do
      let(:column) { "something_nasty" }

      it "does not update the sort column" do
        expect(subject.update(column: column).column).to eq "created_at"
      end

      it "does not update the sort order" do
        expect(subject.update(column: column).order).to eq "desc"
      end
    end

    context "when the column is blank" do
      let(:column) { nil }

      it "does not update the sort column" do
        expect(subject.update(column: column).column).to eq "created_at"
      end

      it "does not update the sort order" do
        expect(subject.update(column: column).order).to eq "desc"
      end
    end
  end
end
