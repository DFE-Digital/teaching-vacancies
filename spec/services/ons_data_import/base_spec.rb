require "rails_helper"

RSpec.describe OnsDataImport::Base, :vcr do
  # this API doesn't exist, so the importer should raise an error
  let(:api_name) { "Counties_and_Unitary_Authorities_April_2019_Boundaries_EW_BUC_2022" }
  let(:name_field) { "CTYUA19NM" }

  it "raises an error" do
    expect { described_class.call(api_name: api_name, name_field: name_field, valid_locations: []) }.to raise_error RuntimeError
  end
end
