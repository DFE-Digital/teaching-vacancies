# frozen_string_literal: true

require "rails_helper"

RSpec.describe Referees::EmploymentReferenceForm do
  context "with no data" do
    let(:form) { described_class.new }

    it "has correct errors" do
      expect(form).not_to be_valid
      expect(form.errors.messages)
        .to eq(
          {
            currently_employed: ["Select yes if the candidate is currently employed in your organisation"],
            how_do_you_know_the_candidate: ["Describe your relationship to the candidate"],
            reason_for_leaving: ["Enter the reason for leaving"],
            employment_start_date: ["Enter the candidate's employment start date"],
            employment_end_date: ["Enter the candidate's employment end date"],
            would_reemploy_any: ["Select yes if you would re-employ the candidate in any role"],
            would_reemploy_any_reason: ["Enter the reason why you would re-employ the candidate"],
            would_reemploy_current: ["Select yes if you would re-employ the candidate in their current role"],
            would_reemploy_current_reason: ["Enter the reason why you would re-employ the candidate in their current role"],
          },
        )
    end
  end

  context "with future start date" do
    let(:form) do
      described_class.new(attributes_for(:job_reference, :reference_given)
                            .slice(*described_class.storable_fields)
                            .merge(employment_start_date: Date.new(3000, 4, 1)))
    end

    it "has errors about dates" do
      expect(form).not_to be_valid
      expect(form.errors.messages)
        .to eq(
          {
            employment_start_date: ["Employment start date cannot be in the future"],
          },
        )
    end
  end

  context "with future end date" do
    let(:form) do
      described_class.new(attributes_for(:job_reference, :reference_given)
                            .slice(*described_class.storable_fields)
                            .merge(employment_end_date: Date.new(3000, 4, 1)))
    end

    it "has errors about dates" do
      expect(form).not_to be_valid
      expect(form.errors.messages)
        .to eq(
          {
            employment_end_date: ["Employment end date cannot be in the future"],
          },
        )
    end
  end

  context "with large text fields" do
    let(:form) do
      described_class.new(attributes_for(:job_reference, :reference_given)
                            .slice(*described_class.storable_fields)
                            .merge(currently_employed: true, how_do_you_know_the_candidate: Faker::Lorem.characters(number: 250)))
    end

    it "has errors about the length" do
      expect(form).not_to be_valid
      expect(form.errors.messages)
        .to eq(
          {
            how_do_you_know_the_candidate: ["Field must not be more than 200 characters"],
          },
        )
    end
  end
end
