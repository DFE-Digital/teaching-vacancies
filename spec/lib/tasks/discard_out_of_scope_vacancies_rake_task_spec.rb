require "rails_helper"

RSpec.describe "vacancies:discard_out_of_scope" do
  include_context "rake"

  let(:in_scope_school) { create(:school, detailed_school_type: "Academy sponsor led") }
  let!(:in_scope_vacancy) { create(:published_vacancy, organisations: [in_scope_school]) }

  # rubocop:disable RSpec/NamedSubject
  it "trashes vacancies from out-of-scope schools" do
    out_of_scope_school = create(:school, detailed_school_type: "Other independent school")
    further_education_school = create(:school, detailed_school_type: "Further education")
    higher_education_school = create(:school, detailed_school_type: "Higher education institutions")

    out_of_scope_vacancy = create(:published_vacancy, organisations: [out_of_scope_school])
    further_ed_vacancy = create(:published_vacancy, organisations: [further_education_school])
    higher_ed_vacancy = create(:published_vacancy, organisations: [higher_education_school])

    expect {
      subject.invoke
    }.to change { PublishedVacancy.kept.count }.by(-3)

    expect(out_of_scope_vacancy.reload).to be_trashed
    expect(further_ed_vacancy.reload).to be_trashed
    expect(higher_ed_vacancy.reload).to be_trashed
    expect(in_scope_vacancy.reload).not_to be_trashed
  end
  # rubocop:enable RSpec/NamedSubject
end
