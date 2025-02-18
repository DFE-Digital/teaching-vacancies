require "rails_helper"

class OnsDataTest < OnsDataImport::Base
  def api_name
    "Counties_and_Unitary_Authorities_April_2019_Boundaries_EW_BUC_2022"
  end

  def name_field
    "CTYUA19NM"
  end

  def in_scope?(_location_name)
    true
  end
end

RSpec.describe OnsDataImport::Base, :vcr do
  it "raises an error" do
    expect { OnsDataTest.new.call }.to raise_error RuntimeError
  end
end
