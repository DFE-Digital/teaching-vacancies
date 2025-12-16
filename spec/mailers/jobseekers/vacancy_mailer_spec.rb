# frozen_string_literal: true

require "rails_helper"

RSpec.describe Jobseekers::VacancyMailer do
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:mail) { described_class.unapplied_saved_vacancy(vacancy, jobseeker) }

  context "without a profile" do
    let(:jobseeker) { build_stubbed(:jobseeker) }

    it "has a nil first name" do
      expect(mail.personalisation).to include(first_name: nil)
    end
  end

  context "with a profile" do
    let(:jobseeker) { build_stubbed(:jobseeker, jobseeker_profile: build_stubbed(:jobseeker_profile, :with_personal_details)) }

    it "has a filled in first name" do
      expect(mail.personalisation).not_to include(first_name: nil)
    end
  end
end
