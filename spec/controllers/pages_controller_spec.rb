require "rails_helper"

RSpec.describe PagesController, type: :controller do
  HighVoltage.page_ids.each do |page|
    context "on GET to /pages/#{page}" do
      before do
        get :show, params: { id: page }
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(page) }

      it "does not have a noindex header" do
        expect(response.headers["X-Robots-Tag"]).to_not include("noindex")
      end
    end
  end
end
