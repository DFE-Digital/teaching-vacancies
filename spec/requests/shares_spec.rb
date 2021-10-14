require "rails_helper"

RSpec.describe "Shares" do
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:vacancy_share_url) { CGI.escape(job_url(vacancy)) }

  describe "GET #new" do
    context "when sharing on facebook" do
      let(:channel) { "facebook" }
      let(:facebook_url) { "https://www.facebook.com/sharer/sharer.php?u=#{vacancy_share_url}" }

      it "redirects to facebook" do
        get new_share_path(channel: channel, vacancy_id: vacancy.id)

        expect(response).to redirect_to(facebook_url)
      end

      it "triggers a `vacancy_share` event" do
        expect { get new_share_path(channel: channel, vacancy_id: vacancy.id) }
          .to have_triggered_event(:vacancy_share)
          .and_data(channel: channel, vacancy_id: vacancy.id)
      end
    end

    context "when sharing on twitter" do
      let(:channel) { "twitter" }
      let(:twitter_url) { "https://twitter.com/share?url=#{vacancy_share_url}&text=#{twitter_text}" }
      let(:twitter_text) { CGI.escape(I18n.t("shares.new.job_at", title: vacancy.job_title, organisation: vacancy.parent_organisation_name)) }

      it "redirects to twitter" do
        get new_share_path(channel: channel, vacancy_id: vacancy.id)

        expect(response).to redirect_to(twitter_url)
      end

      it "triggers a `vacancy_share` event" do
        expect { get new_share_path(channel: channel, vacancy_id: vacancy.id) }
          .to have_triggered_event(:vacancy_share)
          .and_data(channel: channel, vacancy_id: vacancy.id)
      end
    end
  end
end
