# frozen_string_literal: true

require "rails_helper"

module Referees
  RSpec.describe ReferenceInformationForm do
    context "with no data" do
      let(:form) { described_class.new }

      it "has correct errors" do
        expect(form).not_to be_valid
        expect(form.errors.messages)
          .to eq({
            able_to_undertake_role: ["Select yes if the applicant has the ability and is suitable to undertake this role"],
            allegations: ["Select yes if you aware of any allegations or concerns that have been raised about the candidate"],
            not_fit_to_practice: ["Select yes if the applicant has been investigated for, or been found not fit to practice"],
            under_investigation: ["Select yes if the applicant is currently under investigation for any matter"],
            warnings: ["Select yes if there any warnings on the applicant’s record"],
            unable_to_undertake_reason: ["Please enter your concerns"],
          })
      end
    end

    context "with required warning details" do
      let(:form) { described_class.new(allegations: false, not_fit_to_practice: false, warnings: true, under_investigation: true, able_to_undertake_role: false) }

      it "has correct errors" do
        expect(form).not_to be_valid
        expect(form.errors.messages)
          .to eq({
            unable_to_undertake_reason: ["Please enter your concerns"],
            under_investigation_details: ["Please give details"],
            warning_details: ["Please give details"],
          })
      end
    end
  end
end
