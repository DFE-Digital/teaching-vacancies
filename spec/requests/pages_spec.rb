require "rails_helper"

RSpec.describe "Pages" do
  HighVoltage.page_ids.each do |page|
    context "GET /pages/#{page}" do
      before { get page_path(page) }

      it { is_expected.to render_template(page) }

      it "does not have a noindex header" do
        expect(response.headers["X-Robots-Tag"]).to_not include("noindex")
      end

      it "responds with success" do
        expect(response).to have_http_status(:success)
      end
    end
  end
end
