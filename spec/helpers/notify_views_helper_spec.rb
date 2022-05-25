require "rails_helper"

RSpec.describe NotifyViewsHelper do
  describe "#vacancy_location_with_organisation_link" do
    subject do
      helper.vacancy_location_with_organisation_link(vacancy)
    end

    let(:organisation) { create(:school) }
    let(:organisation2) { create(:school) }
    let(:vacancy) { create(:vacancy, organisations: [organisation], job_location: :at_one_school) }
    let(:utm_params) { { utm_source: "a_unique_identifier", utm_medium: "email", utm_campaign: "daily_alert" } }
    let(:url) { helper.organisation_landing_page_url(organisation.slug, utm_params) }

    context "when the vacancy is at a single school" do
      before { allow(helper).to receive(:utm_params).and_return(utm_params) }

      it "generates the correct text with a link with the URL included in the link text" do
        expect(subject).to include("#{helper.notify_link(url, organisation.name)}, #{organisation.town}, #{organisation.county}, #{organisation.postcode}".html_safe)
      end
    end

    context "when the vacancy is at the central office" do
      before do
        allow(helper).to receive(:utm_params).and_return(utm_params)
        vacancy.job_location = :central_office
      end

      it "generates the correct text with a link with the URL included in the link text" do
        expect(subject).to include("#{helper.notify_link(url, organisation.name)}, #{organisation.town}, #{organisation.county}, #{organisation.postcode}".html_safe)
      end
    end

    context "when the vacancy is at multiple schools" do
      before do
        allow(helper).to receive(:utm_params).and_return(utm_params)
        vacancy.organisations.push(organisation2)
        vacancy.job_location = :at_multiple_schools
      end

      it "generates the correct text with a link with the URL included in the link text" do
        expect(subject).to include("#{t('publishers.organisations.readable_job_location.at_multiple_schools')}, #{helper.notify_link(url, organisation.name)}".html_safe)
      end
    end
  end
end
