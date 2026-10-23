require "rails_helper"

RSpec.describe NotifyViewsHelper do
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
