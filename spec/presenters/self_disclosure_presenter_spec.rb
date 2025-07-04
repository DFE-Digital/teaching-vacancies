require "rails_helper"

RSpec.describe SelfDisclosurePresenter do
  subject(:presenter) { described_class.new(job_application) }

  let(:self_disclosure) { create(:self_disclosure) }
  let(:job_application) { self_disclosure.self_disclosure_request.job_application }
  let(:scope) { "jobseekers.job_applications.self_disclosure.review.completed" }

  describe ".personal_details" do
    let(:self_disclosure) { create(:self_disclosure, previous_names: nil) }
    let(:expected_row) do
      {
        name: [I18n.t(".name", scope:), self_disclosure.name],
        previous_names: [I18n.t(".previous_names", scope:), "N/A"],
        address_line_1: [I18n.t(".address_line_1", scope:), self_disclosure.address_line_1],
        address_line_2: [I18n.t(".address_line_2", scope:), self_disclosure.address_line_2],
        city: [I18n.t(".city", scope:), self_disclosure.city],
        country: [I18n.t(".country", scope:), self_disclosure.country],
        postcode: [I18n.t(".postcode", scope:), self_disclosure.postcode],
        phone_number: [I18n.t(".phone_number", scope:), self_disclosure.phone_number],
        date_of_birth: [I18n.t(".date_of_birth", scope:), self_disclosure.date_of_birth.to_fs],
      }
    end

    %i[
      name
      previous_names
      address_line_1
      address_line_2
      city
      country
      postcode
      phone_number
      date_of_birth
    ].each_with_index do |field, idx|
      it "returns personal details #{field}" do
        expect(presenter.personal_details.to_a[idx]).to match_array(expected_row[field])
      end
    end
  end

  describe ".sections" do
    let(:sections) { presenter.sections.to_a }

    it "returns criminal section" do
      expect(sections[0].title).to eq(I18n.t(".criminal", scope:))
      expect(sections[1].title).to eq(I18n.t(".conduct", scope:))
      expect(sections[2].title).to eq(I18n.t(".confirmation", scope:))
    end
  end

  describe ".applicant_name" do
    it { expect(presenter.applicant_name).to eq(job_application.name) }
  end

  describe ".header_text" do
    it { expect(presenter.header_text).to eq(I18n.t("jobseekers.job_applications.self_disclosure.review.completed.self_disclosure_form")) }
  end

  describe ".footer_text" do
    let(:expected) do
      [
        I18n.t("jobseekers.job_applications.self_disclosure.review.completed.self_disclosure_form"),
        job_application.name,
      ].join(" - ")
    end

    it { expect(presenter.footer_text).to eq(expected) }
  end
end
