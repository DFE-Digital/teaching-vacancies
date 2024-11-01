require "rails_helper"

RSpec.describe "jobseekers:delete_unconfirmed_accounts" do
  it "deletes a Jobseeker account that is unconfirmed and not associated with a GovUK OneLogin account" do
    create(:jobseeker, confirmed_at: nil, govuk_one_login_id: nil)
    expect { task.invoke }.to change(Jobseeker, :count).by(-1)
  end

  it "does not delete a Jobseeker account that is unconfirmed and has been associated with a GovUK OneLogin account" do
    create(:jobseeker, confirmed_at: nil, govuk_one_login_id: SecureRandom.alphanumeric(6))
    expect { task.invoke }.not_to change(Jobseeker, :count)
  end

  it "does not delete a Jobseeker account that is confirmed" do
    create(:jobseeker)
    expect { task.invoke }.not_to change(Jobseeker, :count)
  end
end
