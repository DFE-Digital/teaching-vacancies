require "rails_helper"

RSpec.describe "backfill_fe_role_qts_required" do
  let(:college) { create(:college) }
  let(:school) { create(:school) }
  let!(:expired_college_teaching_role) { create(:vacancy, :expired, fe_role_qts_required: nil, organisations: [college]) }
  let!(:college_teaching_role) { create(:vacancy, fe_role_qts_required: nil, organisations: [college]) }
  let!(:future_college_teaching_role) { create(:vacancy, :future_publish, fe_role_qts_required: nil, organisations: [college]) }
  let!(:school_teaching_role) { create(:vacancy, fe_role_qts_required: nil, organisations: [school]) }
  let!(:support_role) { create(:vacancy, :it_support, fe_role_qts_required: nil) }

  # rubocop:disable RSpec/NamedSubject
  before do
    subject.execute
  end
  # rubocop:enable RSpec/NamedSubject

  it "backfills the fe_role_qts_required field" do
    expect([expired_college_teaching_role, college_teaching_role, future_college_teaching_role, school_teaching_role, support_role]
             .map { |x| x.reload.fe_role_qts_required })
      .to eq([nil, true, true, nil, nil])
  end
end
