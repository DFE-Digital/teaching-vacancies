require "rails_helper"

RSpec.describe DSIExportRun do
  subject(:run) { described_class.new(source: "users", total_pages: 2) }

  it { is_expected.to validate_inclusion_of(:source).in_array(described_class::SOURCES) }
  it { is_expected.to validate_numericality_of(:total_pages).is_greater_than(0).only_integer }

  it "defaults to running" do
    expect(run).to be_running
  end

  describe "#all_pages_received?" do
    it "is false until every page has arrived" do
      run.save!
      run.dsi_export_run_pages.create!(page_number: 1, payload: [{ "id" => 1 }])

      expect(run.all_pages_received?).to be false
    end

    it "is true once every page has arrived" do
      run.save!
      run.dsi_export_run_pages.create!(page_number: 1, payload: [{ "id" => 1 }])
      run.dsi_export_run_pages.create!(page_number: 2, payload: [{ "id" => 2 }])

      expect(run.all_pages_received?).to be true
    end
  end
end
