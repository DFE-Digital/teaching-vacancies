require "rails_helper"

RSpec.describe "publishers:reset_accepted_terms_at" do
  include_context "rake"

  let(:task_path) { "lib/tasks/data" }
  let!(:publisher_with_accepted_terms) { create(:publisher, accepted_terms_at: 1.month.ago) }
  let!(:publisher_with_recent_accepted_terms) { create(:publisher, accepted_terms_at: 1.day.ago) }
  let!(:publisher_without_accepted_terms) { create(:publisher, accepted_terms_at: nil) }

  # rubocop:disable RSpec/NamedSubject
  it "sets all publishers accepted_terms_at to nil" do
    expect {
      subject.invoke
    }.to change { publisher_with_accepted_terms.reload.accepted_terms_at }.to(nil)
      .and change { publisher_with_recent_accepted_terms.reload.accepted_terms_at }.to(nil)
      .and(not_change { publisher_without_accepted_terms.reload.accepted_terms_at })
  end

  it "affects all publishers in the database" do
    subject.invoke

    expect(Publisher.where.not(accepted_terms_at: nil).count).to eq(0)
    expect(Publisher.where(accepted_terms_at: nil).count).to eq(3)
  end
  # rubocop:enable RSpec/NamedSubject
end
