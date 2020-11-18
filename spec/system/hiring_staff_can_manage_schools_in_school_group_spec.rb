require "rails_helper"

RSpec.shared_examples "a successful edit" do
  it "allows users to manage the schools and school group details" do
    visit organisation_schools_path

    expect(page).to have_content(I18n.t("hiring_staff.organisations.schools.index.title",
                                        organisation_type: organisation_type_basic(school_group)))
    expect(page).to have_content(school_group.name)
    expect(page).to have_content(
      I18n.t("hiring_staff.organisations.schools.index.schools", count: school_group.schools.not_closed.count),
    )
    expect(page).not_to have_content("Closed school")

    visit edit_organisation_school_path(school_group, school_group: true)

    expect(page).to have_content(school_group.name)

    fill_in "organisation_form[description]", with: "New description of the trust"
    fill_in "organisation_form[website]", with: "https://www.this-is-a-test-url.tvs"
    click_button I18n.t("buttons.save_changes")

    expect(page).to have_content("New description of the trust")
    expect(page).to have_content("Details updated for #{school_group.name}")
    expect(page).to have_content("https://www.this-is-a-test-url.tvs")
    expect(page.current_path).to eql(organisation_schools_path)

    visit edit_organisation_school_path(school_1)

    fill_in "organisation_form[description]", with: "New description of the school"
    fill_in "organisation_form[website]", with: "https://www.this-is-a-test-url.tvs"
    click_button I18n.t("buttons.save_changes")

    expect(page).to have_content("New description of the school")
    expect(page).to have_content("https://www.this-is-a-test-url.tvs")
    expect(page).to have_content("Details updated for #{school_1.name}")
    expect(page.current_path).to eql(organisation_schools_path)
  end
end

RSpec.describe "Schools in your school group" do
  let(:school_1) { create(:school) }
  let(:school_2) { create(:school) }
  let(:school_3) { create(:school) }
  let(:school_4) { create(:school, :closed, name: "Closed school") }

  before do
    allow(LocalAuthorityAccessFeature).to receive(:enabled?).and_return(true)
    allow(ALLOWED_LOCAL_AUTHORITIES).to receive(:include?).with(school_group.local_authority_code).and_return(true)

    SchoolGroupMembership.find_or_create_by(school_id: school_1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_2.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_3.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_4.id, school_group_id: school_group.id)

    stub_accepted_terms_and_conditions
    OmniAuth.config.test_mode = true

    stub_authentication_step(school_urn: nil, trust_uid: school_group.uid, la_code: school_group.local_authority_code)
    stub_authorisation_step
    stub_sign_in_with_multiple_organisations

    visit root_path
    sign_in_user
  end

  after do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  context "when school group is a trust" do
    let(:school_group) { create(:trust) }
    it_behaves_like "a successful edit"
  end

  context "when school group is a local authority" do
    let(:school_group) { create(:local_authority) }
    it_behaves_like "a successful edit"
  end
end
