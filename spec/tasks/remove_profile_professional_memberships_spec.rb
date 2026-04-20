# frozen_string_literal: true

require "rails_helper"

RSpec.describe "remove_profile_professional_memberships" do
  include_context "rake"

  let(:trust) { create(:trust) }
  let(:vacancy) { create(:vacancy, organisations: [trust]) }

  before do
    create(:job_application, vacancy: vacancy, professional_body_memberships: build_list(:professional_body_membership, 1))
    build(:professional_body_membership, job_application: nil).save!(validate: false)
  end

  # rubocop:disable RSpec/NamedSubject
  it "removes profile body memberships only" do
    expect {
      subject.execute
    }.to change(ProfessionalBodyMembership, :count).by(-1)
  end
  # rubocop:enable RSpec/NamedSubject
end
