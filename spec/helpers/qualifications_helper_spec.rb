require "rails_helper"

RSpec.describe QualificationsHelper do
  describe "#qualifications_sort_and_group" do
    it "groups qualifications of same type and sorts into desired order" do
      expect(helper.qualifications_sort_and_group([{ category: "gcse" }, { category: "a_level" }, { category: "undergraduate" }, { category: "gcse" }])).to eq({ "a_level" => [{ :category => "a_level" }], "gcse" => [{ :category => "gcse" }, { :category => "gcse" }], "undergraduate" => [{ :category => "undergraduate" }] })
    end
  end
end
