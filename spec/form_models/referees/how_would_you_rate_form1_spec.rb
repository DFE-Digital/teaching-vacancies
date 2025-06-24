# frozen_string_literal: true

require "rails_helper"

RSpec.describe Referees::HowWouldYouRateForm1 do
  context "with no data" do
    let(:form) { described_class.new }

    it "has correct errors" do
      expect(form).not_to be_valid
      expect(form.errors.messages)
        .to eq({
          adapt_to_change: ["Rate the candidates's capability of adapting to change"],
          customer_care: ["Rate the candidate's customer care skills"],
          deal_with_conflict: ["Rate the candidate's ability to deal with conflicts"],
          prioritise_workload: ["Rate the candidate's ability to prioritise and manage their own workload"],
          punctuality: ["Rate the candidate's punctuality and timekeeping"],
          working_relationships: ["Rate the candidate's working relationships"],
        })
    end
  end
end
