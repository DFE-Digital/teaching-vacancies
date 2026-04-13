# frozen_string_literal: true

require "rails_helper"

module Publishers
  module VacancyTemplates
    RSpec.describe VacancyTemplateStepProcess do
      let(:publisher) { build_stubbed(:publisher) }
      let(:steps) do
        described_class.steps.reject do |step|
          described_class.skip_step?(step, template)
        end
      end

      context "with a simple case" do
        let(:template) { build_stubbed(:vacancy_template) }

        it "misses subjects" do
          expect(steps).to eq(%i[job_role
                                 education_phases
                                 key_stages
                                 contract_information
                                 pay_package
                                 about_the_role
                                 school_visits
                                 visa_sponsorship
                                 applying_for_the_job
                                 how_to_receive_applications
                                 anonymise_applications])
        end
      end

      context "when a secondary school" do
        let(:template) { build_stubbed(:vacancy_template, :secondary) }

        it "shows subjects" do
          expect(steps).to include(:subjects)
        end
      end

      context "when IT support" do
        let(:template) { build_stubbed(:vacancy_template, :it_support) }

        it "skips key_stages" do
          expect(steps).not_to include(:key_stages)
        end
      end
    end
  end
end
