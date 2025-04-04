# frozen_string_literal: true

require "rails_helper"

module Jobseekers
  module JobApplication
    RSpec.describe CatholicForm, type: :model do
      describe "baptism date validation" do
        let(:form) do
          described_class.new({ "baptism_date(3i)" => "1",
                                "following_religion" => "true",
                                "faith" => "RC",
                                "baptism_address" => "1 The Park",
                                "religious_reference_type" => "baptism_date",
                                "catholic_section_completed" => "true",
                                "baptism_date(2i)" => month,
                                "baptism_date(1i)" => year })
        end

        context "with an invalid month" do
          let(:month) { "13" }
          let(:year) { "2024" }

          it "is not valid" do
            expect(form).not_to be_valid
            expect(form.errors.messages).to eq(baptism_date: ["is invalid"])
          end
        end

        context "with a future date" do
          let(:year) { (Date.current.year + 1).to_s }
          let(:month) { "1" }

          it "is not valid" do
            expect(form).not_to be_valid
            expect(form.errors.messages).to eq(baptism_date: ["Baptism date must be in the past"])
          end
        end
      end
    end
  end
end
