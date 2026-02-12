require "rails_helper"

RSpec.describe UpdateDSIUsersInDbJob do
  let(:test_file_2_path) { Rails.root.join("spec/fixtures/dfe_sign_in_service_users_response_page_2.json") }

  # use perform_enqueued to run the child job as well during this test
  it "executes perform", :perform_enqueued do
    update_dsi_users_in_db = instance_double(Publishers::DfeSignIn::FetchDSIUsers)
    expect(Publishers::DfeSignIn::FetchDSIUsers).to receive(:new).and_return(update_dsi_users_in_db)
    expect(update_dsi_users_in_db).to receive(:dsi_users).and_return([JSON.parse(File.read(test_file_2_path)).fetch("users")])

    expect {
      described_class.perform_later
    }.to change(Publisher, :count).by(2)
  end
end
