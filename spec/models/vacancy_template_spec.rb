# frozen_string_literal: true

require "rails_helper"

RSpec.describe VacancyTemplate do
  describe "columns" do
    it "has similar columns to vacancy" do
      expect(Vacancy.columns.map(&:name) - described_class.columns.map(&:name))
        .to match_array(%w[job_title
                           slug
                           job_advert
                           starts_on
                           contact_email
                           publish_on
                           application_link
                           publisher_ats_api_client_id
                           discarded_at
                           type
                           about_school
                           application_email
                           completed_steps
                           contact_number
                           contact_number_provided
                           readable_phases
                           searchable_content
                           start_date_type
                           starts_asap
                           stats_updated_at
                           uk_geolocation
                           earliest_start_date
                           expired_vacancy_feedback_email_sent_at
                           expires_at
                           extension_reason
                           publisher_organisation_id
                           readable_job_location
                           external_advert_url
                           external_reference
                           external_source
                           geolocation
                           other_start_date_details
                           hired_status
                           include_additional_documents
                           job_location
                           latest_start_date
                           listed_elsewhere
                           publisher_id
                           other_extension_reason_details])
    end
  end

  describe "#for_an_fe_college?" do
    it "returns true when the organisation is an FE college" do
      expect(described_class.new(organisation: build(:college))).to be_for_an_fe_college
    end

    it "returns false when the organisation is not an FE college" do
      expect(described_class.new(organisation: build(:school))).not_to be_for_an_fe_college
    end

    it "returns nil when there is no organisation" do
      expect(described_class.new).not_to be_for_an_fe_college
    end
  end

  # This test fails unless vacancy_template overrides reset_application_link to be an empty method
  describe "check that uploaded_form template types can be saved" do
    let(:template) { build(:vacancy_template, organisation: build(:school), enable_job_applications: false, receive_applications: "uploaded_form") }

    it "can be saved" do
      expect(template).to be_valid
      expect(template.errors.messages).to be_empty
      expect(template.save).to be(true)
    end
  end
end
