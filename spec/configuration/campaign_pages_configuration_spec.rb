require "rails_helper"

RSpec.describe "Landing page configuration" do
  it "each configured landing page has a corresponding complete set of translations" do
    keys = %w[banner_title]
    Rails.application.config.campaign_pages.each_key do |cp|
      keys.each do |key|
        i18n_key = "campaign_pages.#{cp}.#{key}"
        expect(I18n.t(i18n_key, default: nil)).not_to be_nil, "Expected a translation for #{i18n_key} but found none"
      end
    end
  end

  it "each campaign page configuration points to an existing banner image" do
    Rails.application.config.campaign_pages.each do |campaign, config|
      expect { ActionController::Base.helpers.image_path(config[:banner_image]) }
        .not_to raise_error, "Image asset for campaign '#{campaign}' does not exist at 'app/assets/images/#{config[:banner_image]}'"
    end
  end

  it "each campaign page configuration with teaching job roles filters by valid roles" do
    Rails.application.config.campaign_pages.each do |campaign, config|
      next if config[:teaching_job_roles].blank?

      config[:teaching_job_roles].each do |job_role| # rubocop:disable Rspect/IteratedExpectation
        expect(job_role).to be_in(Vacancy::TEACHING_JOB_ROLES),
                            "Invalid teaching job role '#{job_role}' for campaign '#{campaign}'" # Needed iterated expectation for this descriptive error
      end
    end
  end

  it "each campaign page configuration with subjects filters by valid subjects" do
    valid_subjects = SUBJECT_OPTIONS.map(&:first) # List of available subjects in the service (from subjects.yml)
    Rails.application.config.campaign_pages.each do |campaign, config|
      next if config[:subjects].blank?

      config[:subjects].each do |subject| # rubocop:disable Rspec/IteratedExpectation
        expect(subject).to be_in(valid_subjects),
                           "Invalid subject '#{subject}' for campaign '#{campaign}'" # Needed iterated expectation for this descriptive error
      end
    end
  end
end
