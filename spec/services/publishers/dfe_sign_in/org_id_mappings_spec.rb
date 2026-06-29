require "rails_helper"

RSpec.describe Publishers::DfeSignIn::OrgIdMappings do
  describe "OUT_OF_SCOPE_TYPES" do
    it "contains exactly the same organisation types as Organisation::OUT_OF_SCOPE_DETAILED_SCHOOL_TYPES" do
      dsi_out_of_scope_names = described_class::OUT_OF_SCOPE_TYPES.values

      expect(dsi_out_of_scope_names).to match_array(Organisation::OUT_OF_SCOPE_DETAILED_SCHOOL_TYPES)
    end
  end

  describe ".out_of_scope_type?" do
    it "returns true for an out-of-scope type id" do
      expect(described_class.out_of_scope_type?("18")).to be true # Further education
    end

    it "returns false for an in-scope type id" do
      expect(described_class.out_of_scope_type?("01")).to be false
    end

    it "returns false for nil" do
      expect(described_class.out_of_scope_type?(nil)).to be false
    end
  end
end
