require "rails_helper"

RSpec.describe NotifyViewsHelper do
  describe "#vacancy_organisation_and_location" do
    subject { helper.vacancy_organisation_and_location(vacancy) }

    let(:school) { create(:school, school_groups: [school_group]) }
    let(:school2) { create(:school, school_groups: [school_group]) }
    let(:school_group) { create(:school_group) }

    context "when the vacancy is at a single school" do
      let(:vacancy) { create(:vacancy, organisations: [school]) }

      it "returns the address without organization name" do
        expect(subject).to eq("#{school.town}, #{school.county}, #{school.postcode}")
      end
    end

    context "when the vacancy is at multiple schools" do
      let(:vacancy) { create(:vacancy, organisations: [school, school2]) }

      it "returns the multiple locations text with organization name" do
        expect(subject).to eq("#{t('organisations.job_location_summary.at_multiple_locations')}, #{school_group.name}")
      end
    end
  end

  describe "#publisher_email_opt_out_link" do
    it "returns nil when no publisher is provided" do
      expect(helper.publisher_email_opt_out_link(nil)).to be_nil
    end

    it "generates the opt out link for the publisher" do
      publisher = build_stubbed(:publisher)
      expected_link = helper.confirm_email_opt_out_publishers_account_url(publisher_id: publisher.signed_id)

      expect(helper.publisher_email_opt_out_link(publisher))
        .to eq(helper.notify_link(expected_link, "Stop receiving emails from Teaching Vacancies"))
    end
  end

  describe "#publisher_candidate_messages_link" do
    let(:utm_params) { { utm_source: "a_unique_identifier", utm_medium: "email", utm_campaign: "daily_alert" } }

    before { allow(helper).to receive(:utm_params).and_return(utm_params) }

    it "generates the candidate messages link with UTM parameters" do
      expected_url = helper.publishers_candidate_messages_url(utm_params)
      expected_link = helper.notify_link(expected_url, "View your messages")

      expect(helper.publisher_candidate_messages_link).to eq(expected_link)
    end
  end
end
