require "rails_helper"

RSpec.describe Publishers::CandidateMessagesSearchForm do
  describe "#clear_filters_params" do
    it "returns empty hash" do
      form = described_class.new(keyword: "teacher")
      expect(form.clear_filters_params).to eq({})
    end
  end
end