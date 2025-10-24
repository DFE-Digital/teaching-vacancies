# frozen_string_literal: true

require "rails_helper"

RSpec.describe JobApplicationDecorator do
  describe "#first_name" do
    subject(:first) { job_application.decorate.first_name }

    let(:first_name) { Faker::Name.first_name }
    let(:job_application) { build_stubbed(:job_application, :status_submitted, vacancy: vacancy, first_name: first_name) }

    context "with a normal vacancy" do
      let(:vacancy) { build_stubbed(:vacancy) }

      it "shows the name" do
        expect(first).to eq(first_name)
      end
    end

    context "with an anonymised vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, anonymise_applications: true) }

      it "does not show the name" do
        expect(first).not_to eq(first_name)
      end
    end
  end

  # if field is blank, decorator doesn't need to hide it
  describe "#national_insurance_number" do
    subject(:first) { job_application.decorate.national_insurance_number }

    let(:vacancy) { build_stubbed(:vacancy, anonymise_applications: true) }
    let(:job_application) do
      build_stubbed(:job_application, :status_submitted, vacancy: vacancy,
                                                         national_insurance_number: national_insurance_number)
    end

    context "with a value" do
      let(:national_insurance_number) { "QQ 12 34 56" }

      it "shows the name" do
        expect(first).not_to eq(national_insurance_number)
      end
    end

    context "without a value" do
      let(:national_insurance_number) { "" }

      it "does not show the name" do
        expect(first).to be_blank
      end
    end
  end
end
