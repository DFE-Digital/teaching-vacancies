# frozen_string_literal: true

require "rails_helper"

RSpec.describe Referees::HowWouldYouRateForm2 do
  context "with no data" do
    let(:form) { described_class.new }

    it "has correct errors" do
      expect(form).not_to be_valid
      expect(form.errors.messages)
        .to eq({
          communication: ["Rate the candidate's communication skills"],
          general_attitude: ["Rate the candidate's general attitude"],
          leadership: ["Rate the candidate's leadership skills (if relevant)"],
          problem_solving: ["Rate the candidate's problem solving skills"],
          team_working: ["Rate the candidate's team working skills"],
          technical_competence: ["Rate the candidate's technical competence (if relevant)"],
        })
    end
  end
end
