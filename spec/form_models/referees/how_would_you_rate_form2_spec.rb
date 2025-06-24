# frozen_string_literal: true

require "rails_helper"

RSpec.describe Referees::HowWouldYouRateForm2 do
  context "with no data" do
    let(:form) { described_class.new }

    it "has correct errors" do
      expect(form).not_to be_valid
      expect(form.errors.messages)
        .to eq({
          deal_with_conflict: ["Rate the candidate's ability to deal with conflicts"],
          prioritise_workload: ["Rate the candidate's ability to prioritise and manage their own workload"],
          communication: ["Rate the candidate's communication skills"],
          team_working: ["Rate the candidate's team working skills"],
        })
    end
  end
end
