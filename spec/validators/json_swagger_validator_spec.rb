# frozen_string_literal: true

require "rails_helper"

RSpec.describe "JsonSwaggerValidator" do
  let(:validator) { JsonSwaggerValidator.new("/ats-api/v1/vacancies", "post") }
  let(:vacancy) do
    attributes_for(:vacancy, :external)
                               .compact
                               .except(:enable_job_applications, :contact_number_provided,
                                       :contact_number, :fixed_term_contract_duration, :further_details_provided,
                                       :hired_status, :include_additional_documents,
                                       :listed_elsewhere, :ect_status, :school_visits,
                                       :start_date_type, :status,
                                       :working_patterns_details, :organisations,
                                       :further_details, :hourly_rate, :pay_scale,
                                       :flexi_working_details_provided, :flexi_working, :about_school, :how_to_apply,
                                       :personal_statement_guidance, :external_source,
                                       :expires_at, :publish_on, :starts_on,
                                       :benefits, :completed_steps, :contact_email)
                               .merge(expires_at: "xx", schools: { trust_uid: "27" })
  end

  context "when complete" do
    let(:payload) { { vacancy: vacancy } }

    it "is valid" do
      expect(validator.valid?(payload)).to be(true)
    end

    it "has no errors" do
      expect(validator.errors(payload)).to eq([])
    end
  end

  context "with an invalid set of phases" do
    let(:payload) { { vacancy: vacancy.merge(phases: %w[notaphase]) } }

    it "is not valid" do
      expect(validator.valid?(payload)).to be(false)
    end

    it "has relevant errors" do
      expect(validator.errors(payload).map { |x| /(.+) in schema/.match(x)[1] })
        .to eq(["The property '#/vacancy/phases/0' value \"notaphase\" did not match one of the following values: nursery, primary, secondary, sixth_form_or_college, through"])
    end
  end
end
