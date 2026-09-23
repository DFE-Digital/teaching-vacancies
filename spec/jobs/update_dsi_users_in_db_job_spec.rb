require "rails_helper"

RSpec.describe UpdateDSIUsersInDbJob do
  # DSI returns one record per user per organisation, so a user in two organisations
  # appears twice with the same userId.
  let(:multi_organisation_user_id) { SecureRandom.uuid.upcase }
  let(:first_page_users) do
    [
      build(:dsi_user),
      build(:dsi_user, user_id: multi_organisation_user_id, school_urn: "100001"),
    ]
  end
  let(:second_page_users) do
    [
      build(:dsi_user, user_id: multi_organisation_user_id, school_urn: "100002"),
      build(:dsi_user, :trust),
    ]
  end

  before do
    # DfeSignIn::API.users already hides pagination, so this job's own spec doesn't need to
    # know about pages either — it stubs the enumerator directly, same as the job consumes it.
    allow(DfeSignIn::API).to receive(:users).and_return((first_page_users + second_page_users).each)
  end

  it "creates a publisher for each distinct user across the source", :perform_enqueued do
    # multi_organisation_user_id appears twice, so there are 3 distinct users across 4 records.
    expect { described_class.perform_later }.to change(Publisher, :count).by(3)
  end

  it "enqueues one UpdateSingleDSIUserInDbJob per user DfeSignIn::API.users yields" do
    # perform_now rather than perform_later + perform_enqueued_jobs: this only needs to run
    # UpdateDSIUsersInDbJob itself and check what it enqueues, not cascade into actually
    # performing every UpdateSingleDSIUserInDbJob too (the first example already covers that).
    expect { described_class.new.perform_now }
      .to have_enqueued_job(UpdateSingleDSIUserInDbJob).exactly(first_page_users.size + second_page_users.size).times
  end
end
