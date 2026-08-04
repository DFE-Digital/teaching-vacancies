# frozen_string_literal: true

require "rails_helper"

module Jobseekers
  module JobApplication
    RSpec.describe PreSubmitForm, type: :model do
      subject(:form) { described_class.new(all_steps: all_steps, completed_steps: completed_steps) }

      let(:all_steps) { %w[personal_details professional_status qualifications training_and_cpds professional_body_memberships employment_history personal_statement catholic non_catholic referees equal_opportunities ask_for_support declarations] }

      context "when all steps are completed" do
        let(:completed_steps) { all_steps }

        it { is_expected.to be_valid }
      end

      context "when steps are incomplete" do
        let(:completed_steps) { [] }

        it "shows the correct error messages" do
          expect(form).not_to be_valid
          expect(form.errors.map(&:message)).to contain_exactly(
            "Complete your personal details",
            "Complete the questions about your professional status",
            "Complete your qualifications",
            "Complete your training and CPD",
            "Complete your professional body memberships",
            "Complete your employment history",
            "Complete your personal statement",
            "Complete your religious information",
            "Complete your religious information",
            "Complete your references",
            "Complete the questions on equal opportunities",
            "Complete the questions on interview support",
            "Complete the declarations",
          )
        end
      end
    end
  end
end
