# frozen_string_literal: true

require "rails_helper"

RSpec.describe Jobseekers::VacancyMailer do
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:mail) { described_class.unapplied_saved_vacancy(vacancy, jobseeker) }

  context "without a profile" do
    let(:jobseeker) { build_stubbed(:jobseeker) }

    it "has a fallback 'Jobseeker' as a first name" do
      expect(mail.personalisation).to include(first_name: "Jobseeker")
    end
  end
end
