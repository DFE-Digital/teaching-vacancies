# frozen_string_literal: true

require "rails_helper"

RSpec.describe Referees::HowWouldYouRateForm do
  context "with no data" do
    let(:form) { described_class.new }

    it "has correct errors" do
      expect(form).not_to be_valid
      expect(form.errors.messages)
        .to eq({
          adapt_to_change: ["Rate the candidates's capability of adapting to change"],
          communication: ["Rate the candidate's communication skills"],
          customer_care: ["Rate the candidate's customer care skills"],
          deal_with_conflict: ["Rate the candidate's ability to deal with conflicts"],
          general_attitude: ["Rate the candidate's general attitude"],
          leadership: ["Rate the candidate's leadership skills (if relevant)"],
          prioritise_workload: ["Rate the candidate's ability to prioritise and manage their own workload"],
          problem_solving: ["Rate the candidate's problem solving skills"],
          punctuality: ["Rate the candidate's punctuality and timekeeping"],
          team_working: ["Rate the candidate's team working skills"],
          technical_competence: ["Rate the candidate's technical competence (if relevant)"],
          working_relationships: ["Rate the candidate's working relationships"],
        })
    end
  end
end
