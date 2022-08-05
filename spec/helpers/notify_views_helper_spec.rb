require "rails_helper"

RSpec.describe NotifyViewsHelper do
  describe "#vacancy_location_with_organisation_link" do
    subject { helper.vacancy_location_with_organisation_link(vacancy) }

    let(:school) { create(:school, school_groups: [school_group]) }
    let(:school2) { create(:school, school_groups: [school_group]) }
    let(:school_group) { create(:school_group) }
    let(:utm_params) { { utm_source: "a_unique_identifier", utm_medium: "email", utm_campaign: "daily_alert" } }
    let(:url) { helper.organisation_landing_page_url(organisation.slug, utm_params) }

    context "when the vacancy is at a single school" do
      let(:organisation) { school }
      let(:vacancy) { create(:vacancy, organisations: [organisation]) }

      before { allow(helper).to receive(:utm_params).and_return(utm_params) }

      it "generates the correct text with a link with the URL included in the link text" do
        expect(subject).to include("#{helper.notify_link(url, organisation.name)}, #{organisation.town}, #{organisation.county}, #{organisation.postcode}".html_safe)
      end
    end

    context "when the vacancy is at the central office" do
      let(:organisation) { school_group }
      let(:vacancy) { create(:vacancy, organisations: [school_group]) }

      before { allow(helper).to receive(:utm_params).and_return(utm_params) }

      it "generates the correct text with a link with the URL included in the link text" do
        expect(subject).to include(helper.notify_link(url, school_group.name).to_s.html_safe)
      end
    end

    context "when the vacancy is at multiple schools" do
      let(:organisation) { school_group }
      let(:vacancy) { create(:vacancy, organisations: [school, school2]) }

      before { allow(helper).to receive(:utm_params).and_return(utm_params) }

      it "generates the correct text with a link with the URL included in the link text" do
        expect(subject).to include("#{t('organisations.job_location_summary.at_multiple_locations')}, #{helper.notify_link(url, organisation.name)}".html_safe)
      end
    end
  end
end
