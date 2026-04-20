# frozen_string_literal: true

require "rails_helper"

module Publishers
  module Vacancies
    module JobApplications
      RSpec.describe RefereeForm do
        context "with invalid email" do
          let(:form) { described_class.new(email: "invalid") }

          it "has correct error message" do
            expect(form).not_to be_valid
            expect(form.errors[:email]).to include("Enter a valid email address in the correct format, like name@example.com")
          end
        end

        context "with valid email" do
          let(:form) do
            described_class.new(
              name: "Jane Smith",
              uploaded_details: false,
              job_title: "Head of Year",
              organisation: "Test School",
              relationship: "Manager",
              email: Faker::Internet.email(domain: TEST_EMAIL_DOMAIN),
            )
          end

          it "is valid" do
            expect(form).to be_valid
          end
        end
      end
    end
  end
end
