require "rails_helper"

RSpec.describe "Fallback Support User sign in" do
  include ActiveJob::TestHelper

  let!(:support_user) { create(:support_user, email: "rachael@example.com") }

  before do
    allow(AuthenticationFallback).to receive(:enabled?).and_return(true)
  end

  it "allows support users to sign in" do
    visit new_support_user_session_path
    fill_in "support_user[email]", with: "rachael@example.com"

    expect { perform_enqueued_jobs { click_on "Submit" } }
      .to change { delivered_emails.count }
      .by(1)

    visit first_link_from_last_mail
    expect(current_path).to eq(support_user_root_path)
  end
end
