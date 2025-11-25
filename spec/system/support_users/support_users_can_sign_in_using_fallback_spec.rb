require "rails_helper"

RSpec.describe "Fallback Support User sign in" do
  include ActiveJob::TestHelper

  let(:support_user) { create(:support_user, email: "rachael@example.com") }

  before do
    allow(AuthenticationFallback).to receive(:enabled?).and_return(true)
  end

  it "allows support users to sign in", :perform_enqueued do
    visit support_user_root_path
    fill_in "support_user[email]", with: support_user.email

    expect { click_on "Submit" }
      .to change(delivered_emails, :count)
      .by(1)

    # make email link work even when :js is enabled for debugging
    if page.server
      visit first_link_from_last_mail.gsub("3000", page.server.port.to_s)
    else
      visit first_link_from_last_mail
    end
    expect(page).to have_current_path(support_user_root_path, ignore_query: true)
  end
end
