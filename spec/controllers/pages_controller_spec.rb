require "rails_helper"

RSpec.describe PagesController, type: :controller do
  PAGES_WITH_NOINDEX_HEADER = %w[user-not-authorised home].freeze

  HighVoltage.page_ids.each do |page|
    context "on GET to /pages/#{page}" do
      before do
        get :show, params: { id: page }
      end

      it { should respond_with(:success) }
      it { should render_template(page) }

      if PAGES_WITH_NOINDEX_HEADER.include?(page)
        it "should have a noindex header" do
          expect(response.headers["X-Robots-Tag"]).to include("noindex")
        end
      else
        it "should not have a noindex header" do
          expect(response.headers["X-Robots-Tag"]).to_not include("noindex")
        end
      end
    end
  end
end
