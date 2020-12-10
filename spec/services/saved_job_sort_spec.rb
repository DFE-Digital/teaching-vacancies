require "rails_helper"

RSpec.describe SavedJobSort do
  let(:subject) { described_class.new }

  describe "#initialize" do
    it "sets the column and order to the provided defaults" do
      expect(subject.column).to eq("created_at")
      expect(subject.order).to eq("desc")
    end
  end

  describe "#update" do
    it "sets the given column if it is valid" do
      expect(subject.update(column: "vacancies.expires_at", order: anything).column).to eq "vacancies.expires_at"
    end

    it "sets the given order if it is valid" do
      expect(subject.update(column: anything, order: "asc").order).to eq "asc"
    end

    it "sets default column if none is provided" do
      expect(subject.update(column: nil, order: anything).column).to eq "created_at"
    end

    it "sets default order if none is provided" do
      expect(subject.update(column: anything, order: nil).order).to eq "desc"
    end

    it "sets default column if an invalid one is provided" do
      expect(subject.update(column: "job_summary", order: anything).column).to eq "created_at"
    end

    it "sets default order if an invalid one is provided" do
      expect(subject.update(column: anything, order: "sideways").order).to eq "desc"
    end
  end
end
