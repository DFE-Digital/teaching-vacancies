require "rails_helper"
RSpec.describe VacancySort do
  subject(:vacancy_sort) { VacancySort.new(default_column: "expires_on", default_order: "asc") }

  describe "#initialize" do
    it "sets the column and order to the provided defaults" do
      expect(vacancy_sort.column).to eq("expires_on")
      expect(vacancy_sort.order).to eq("asc")
    end
  end

  describe "#update" do
    it "sets the given column if it is valid" do
      expect(vacancy_sort.update(column: "job_title", order: anything).column).to eq "job_title"
    end

    it "sets the given order if it is valid" do
      expect(vacancy_sort.update(column: anything, order: "asc").order).to eq "asc"
    end

    it "sets default column if none is provided" do
      expect(vacancy_sort.update(column: nil, order: anything).column).to eq "expires_on"
    end

    it "sets default order if none is provided" do
      expect(vacancy_sort.update(column: anything, order: nil).order).to eq "asc"
    end

    it "sets default column if an invalid one is provided" do
      expect(vacancy_sort.update(column: "job_summary", order: anything).column).to eq "expires_on"
    end

    it "sets default order if an invalid one is provided" do
      expect(vacancy_sort.update(column: anything, order: "sideways").order).to eq "asc"
    end
  end
end
